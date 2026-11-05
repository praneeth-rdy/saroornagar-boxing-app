import 'package:flutter/material.dart' show TimeOfDay;
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/core/utils/india_date.dart';
import 'package:saroornagar_boxing/features/today/data/attendance_repository.dart';
import 'package:saroornagar_boxing/features/today/domain/attendance_mark.dart';
import 'package:saroornagar_boxing/features/today/domain/club_session.dart';
import 'package:saroornagar_boxing/features/today/domain/roster_entry.dart';
import 'package:saroornagar_boxing/features/trials/domain/trial_booking.dart';

import '../fixtures/profiles.dart';
import '../fixtures/roster.dart';
import '../fixtures/sessions.dart';
import '../scenario.dart';

/// In-memory [AttendanceRepository] that follows the attendance migration's rules and
/// messages (`20261105075401_trainees_sessions`, `20261105080014_attendance_trials`,
/// `20261105114625_unmark_attendance`, `roll_numbers`; the roster is by roll number).
class MockAttendanceRepository implements AttendanceRepository {
  MockAttendanceRepository({
    this.scenario = MockScenario.success,
    List<FixtureTrainee>? trainees,
    List<AttendanceMark> marks = const [],
    List<ClubSession> extraSessions = const [],
    this.trials = const [],
    String? staffId,
    DateTime Function()? now,
  }) : trainees = trainees ?? typicalTrainees,
       staffId = staffId ?? adminProfile.id,
       now = now ?? (() => DateTime.now().toUtc()) {
    for (final mark in marks) {
      _marks[_markKey(mark.sessionId, mark.traineeId)] = mark;
    }
    for (final session in extraSessions) {
      _dayOf(session.sessionDate).add(session);
    }
  }

  MockScenario scenario;
  final List<FixtureTrainee> trainees;
  final List<TrialBooking> trials;

  /// The signed-in staff member recorded as `created_by` and `marked_by`.
  final String staffId;

  /// The instant stored as `marked_at`.
  final DateTime Function() now;

  final _sessionsByDate = <String, List<ClubSession>>{};
  final _marks = <String, AttendanceMark>{};
  var _extraCount = 0;

  /// Every `mark` call as sent, oldest first, for assertions.
  final markCalls = <({String sessionId, String traineeId})>[];

  /// The stored mark, for assertions.
  AttendanceMark? markFor(String sessionId, String traineeId) =>
      _marks[_markKey(sessionId, traineeId)];

  @override
  Future<List<ClubSession>> sessionsFor(DateTime date) => applyScenario(
    scenario,
    success: () {
      final day = _dayOf(date);
      if (date.weekday != DateTime.sunday) {
        for (final regular in [morningSession(date), eveningSession(date)]) {
          if (!day.any((session) => session.slot == regular.slot)) {
            day.add(regular);
          }
        }
      }
      return [...day]..sort(_byTime);
    },
    empty: () => const [],
  );

  @override
  Future<ClubSession> addExtraSession(
    DateTime date,
    TimeOfDay start,
    TimeOfDay end,
  ) => applyScenario(
    scenario,
    success: () {
      if (end.hour * 60 + end.minute <= start.hour * 60 + start.minute) {
        throw const ValidationException(
          'End time must be after the start time',
        );
      }
      _extraCount++;
      final session = ClubSession(
        id: 'session-extra-$_extraCount',
        sessionDate: dateOnly(date),
        slot: SessionSlot.extra,
        startsAt: _wireTime(start),
        endsAt: _wireTime(end),
        createdBy: staffId,
      );
      _dayOf(date).add(session);
      return session;
    },
  );

  @override
  Future<void> deleteExtraSession(String sessionId) => applyScenario<void>(
    scenario,
    success: () {
      final session = _session(sessionId);
      if (session.slot != SessionSlot.extra) {
        throw const ValidationException('Only extra sessions can be removed');
      }
      if (_marks.values.any((mark) => mark.sessionId == sessionId)) {
        throw const ValidationException('This session already has attendance');
      }
      _dayOf(session.sessionDate).removeWhere((other) => other.id == sessionId);
    },
  );

  @override
  Future<List<RosterEntry>> roster(String sessionId) => applyScenario(
    scenario,
    success: () {
      _session(sessionId);
      final active = trainees.where((trainee) => trainee.isActive).toList()
        ..sort((a, b) => a.rollNo.compareTo(b.rollNo));
      return [
        for (final trainee in active)
          RosterEntry(
            traineeId: trainee.id,
            rollNo: trainee.rollNo,
            fullName: trainee.fullName,
            photoPath: trainee.photoPath,
            status: markFor(sessionId, trainee.id)?.status,
            markedAt: markFor(sessionId, trainee.id)?.markedAt,
          ),
      ];
    },
    empty: () => const [],
  );

  @override
  Future<AttendanceMark> mark(
    String sessionId,
    String traineeId,
    AttendanceStatus status,
  ) {
    markCalls.add((sessionId: sessionId, traineeId: traineeId));
    return _markStored(sessionId, traineeId, status);
  }

  Future<AttendanceMark> _markStored(
    String sessionId,
    String traineeId,
    AttendanceStatus status,
  ) => applyScenario(
    scenario,
    success: () {
      _session(sessionId);
      final trainee = _trainee(traineeId);
      if (!trainee.isActive) {
        throw const ValidationException('This trainee is inactive');
      }
      if (status == AttendanceStatus.unknown) {
        throw const ValidationException('Choose present or absent');
      }
      final stored = markFor(sessionId, traineeId);
      // The same status is a no-op that returns the original marker and time.
      if (stored != null && stored.status == status) return stored;
      final mark = AttendanceMark(
        sessionId: sessionId,
        traineeId: traineeId,
        status: status,
        markedBy: staffId,
        markedAt: now(),
      );
      _marks[_markKey(sessionId, traineeId)] = mark;
      return mark;
    },
  );

  @override
  Future<void> unmark(String sessionId, String traineeId) =>
      applyScenario<void>(
        scenario,
        success: () {
          _session(sessionId);
          // No trainee status check, as the server: an inactive trainee's mark can go.
          if (_marks.remove(_markKey(sessionId, traineeId)) == null) {
            throw const NotFoundException('No mark to remove');
          }
        },
      );

  @override
  Future<int> resetSession(String sessionId) => applyScenario(
    scenario,
    success: () {
      _session(sessionId);
      final before = _marks.length;
      _marks.removeWhere((_, mark) => mark.sessionId == sessionId);
      return before - _marks.length;
    },
  );

  @override
  Future<List<TrialBooking>> trialsBetween(DateTime from, DateTime to) =>
      applyScenario(
        scenario,
        success: () {
          final first = dateOnly(from);
          final last = dateOnly(to);
          if (last.isBefore(first)) {
            throw const ValidationException(
              'The end date is before the start date',
            );
          }
          return trials
              .where(
                (booking) =>
                    !booking.sessionDate.isBefore(first) &&
                    !booking.sessionDate.isAfter(last),
              )
              .toList()
            ..sort(_byBookingOrder);
        },
        empty: () => const [],
      );

  List<ClubSession> _dayOf(DateTime date) =>
      _sessionsByDate.putIfAbsent(wireDate(date), () => []);

  ClubSession _session(String sessionId) {
    for (final day in _sessionsByDate.values) {
      for (final session in day) {
        if (session.id == sessionId) return session;
      }
    }
    throw const NotFoundException('Session not found');
  }

  FixtureTrainee _trainee(String traineeId) {
    for (final trainee in trainees) {
      if (trainee.id == traineeId) return trainee;
    }
    throw const NotFoundException('Trainee not found');
  }
}

String _markKey(String sessionId, String traineeId) => '$sessionId/$traineeId';

String _wireTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}:00';

// Same order as the server: start, then end.
int _byTime(ClubSession a, ClubSession b) {
  final byStart = a.startsAt.compareTo(b.startsAt);
  return byStart != 0 ? byStart : a.endsAt.compareTo(b.endsAt);
}

// Same order as the server: date, batch (enum order), created_at.
int _byBookingOrder(TrialBooking a, TrialBooking b) {
  final byDate = a.sessionDate.compareTo(b.sessionDate);
  if (byDate != 0) return byDate;
  final bySlot = a.slot.index.compareTo(b.slot.index);
  return bySlot != 0 ? bySlot : a.createdAt.compareTo(b.createdAt);
}
