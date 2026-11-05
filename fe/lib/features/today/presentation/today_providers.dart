import 'dart:async';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/attendance_status.dart';
import '../../../core/utils/india_date.dart';
import '../../trials/domain/trial_booking.dart';
import '../domain/club_session.dart';
import '../domain/roster_entry.dart';

/// India wall-clock time (see `indiaNow`); tests override it to pin the day and hour.
final clockProvider = Provider<DateTime Function()>((ref) => indiaNow);

final selectedDateProvider =
    NotifierProvider.autoDispose<SelectedDate, DateTime>(SelectedDate.new);

final daySessionsProvider = FutureProvider.autoDispose
    .family<List<ClubSession>, DateTime>(
      (ref, date) => ref.watch(attendanceRepositoryProvider).sessionsFor(date),
    );

/// Keyed by the day, so a choice made on one day never carries over to another.
final selectedSessionIdProvider = NotifierProvider.autoDispose
    .family<SelectedSessionId, String?, DateTime>(SelectedSessionId.new);

final rosterProvider = AsyncNotifierProvider.autoDispose
    .family<RosterNotifier, List<RosterEntry>, String>(RosterNotifier.new);

final dayTrialsProvider = FutureProvider.autoDispose
    .family<List<TrialBooking>, DateTime>(
      (ref, date) =>
          ref.watch(attendanceRepositoryProvider).trialsBetween(date, date),
    );

final markControllerProvider = AsyncNotifierProvider.autoDispose
    .family<MarkController, void, DateTime>(MarkController.new);

final addExtraSessionControllerProvider =
    NotifierProvider.autoDispose<AddExtraSessionController, AsyncValue<void>>(
      AddExtraSessionController.new,
    );

final deleteExtraSessionControllerProvider =
    NotifierProvider.autoDispose<
      DeleteExtraSessionController,
      AsyncValue<void>
    >(DeleteExtraSessionController.new);

/// The first session that has not ended at [now], else the day's last one.
String? defaultSessionIdFor(List<ClubSession> sessions, DateTime now) {
  if (sessions.isEmpty) return null;
  for (final session in sessions) {
    if (session.endsAtMoment.isAfter(now)) return session.id;
  }
  return sessions.last.id;
}

/// The day on screen; starts at today's India date.
class SelectedDate extends Notifier<DateTime> {
  @override
  DateTime build() => dateOnly(ref.read(clockProvider)());

  void select(DateTime date) => state = dateOnly(date);
}

/// The session on screen for [date]; falls back to the default whenever the choice is not
/// in that day.
class SelectedSessionId extends Notifier<String?> {
  SelectedSessionId(this.date);

  final DateTime date;

  @override
  String? build() {
    final sessions = ref.watch(daySessionsProvider(date));
    final loaded = sessions.value;
    if (loaded == null) return null;
    final current = stateOrNull;
    // Keeps a choice made while this same day reloads, such as a session just added.
    if (sessions.isLoading && current != null) return current;
    if (current != null && loaded.any((session) => session.id == current)) {
      return current;
    }
    return defaultSessionIdFor(loaded, ref.read(clockProvider)());
  }

  void select(String? sessionId) => state = sessionId;
}

/// One session's roster; [MarkController] swaps entries in for optimistic marks.
class RosterNotifier extends AsyncNotifier<List<RosterEntry>> {
  RosterNotifier(this.sessionId);

  final String sessionId;

  @override
  Future<List<RosterEntry>> build() =>
      ref.watch(attendanceRepositoryProvider).roster(sessionId);

  RosterEntry? entryFor(String traineeId) {
    for (final entry in state.value ?? const <RosterEntry>[]) {
      if (entry.traineeId == traineeId) return entry;
    }
    return null;
  }

  /// Replaces the entry with the same trainee; a roster still loading is left alone.
  void replace(RosterEntry entry) {
    final entries = state.value;
    if (entries == null) return;
    state = AsyncData([
      for (final current in entries)
        current.traineeId == entry.traineeId ? entry : current,
    ]);
  }
}

/// Present marks for one day: optimistic marks and removals, the session reset, and a retry.
///
/// Every call names the session from the row on screen and is refused unless that session
/// belongs to [date]. Loading means a reset is running; an error is the last failed
/// action, made on [failedSessionId].
class MarkController extends AsyncNotifier<void> {
  MarkController(this.date);

  final DateTime date;
  Future<void> Function()? _retry;

  /// The session the error in state is about.
  String? failedSessionId;

  @override
  FutureOr<void> build() {}

  /// Marks the trainee present; a legacy absent mark is corrected to present.
  Future<void> mark(String sessionId, String traineeId) async {
    if (!_belongsToDay(sessionId)) return;
    final previous = ref
        .read(rosterProvider(sessionId).notifier)
        .entryFor(traineeId);
    if (previous == null || previous.status == AttendanceStatus.present) {
      return;
    }
    _replace(
      sessionId,
      previous.copyWith(status: AttendanceStatus.present, markedAt: null),
    );
    try {
      final stored = await ref
          .read(attendanceRepositoryProvider)
          .mark(sessionId, traineeId, AttendanceStatus.present);
      if (!ref.mounted) return;
      _replace(
        sessionId,
        previous.copyWith(status: stored.status, markedAt: stored.markedAt),
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      _replace(sessionId, previous);
      _fail(sessionId, error, stackTrace, () => mark(sessionId, traineeId));
    }
  }

  /// Removes the trainee's present mark.
  Future<void> unmark(String sessionId, String traineeId) async {
    if (!_belongsToDay(sessionId)) return;
    final previous = ref
        .read(rosterProvider(sessionId).notifier)
        .entryFor(traineeId);
    if (previous == null || previous.status != AttendanceStatus.present) {
      return;
    }
    _replace(sessionId, previous.copyWith(status: null, markedAt: null));
    try {
      await ref.read(attendanceRepositoryProvider).unmark(sessionId, traineeId);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      _replace(sessionId, previous);
      _fail(sessionId, error, stackTrace, () => unmark(sessionId, traineeId));
    }
  }

  /// Returns how many marks were removed, or null when it failed (the error is in state).
  Future<int?> resetSession(String sessionId) async {
    if (state.isLoading || !_belongsToDay(sessionId)) return null;
    state = const AsyncLoading();
    try {
      final count = await ref
          .read(attendanceRepositoryProvider)
          .resetSession(sessionId);
      if (!ref.mounted) return count;
      state = const AsyncData(null);
      ref.invalidate(rosterProvider(sessionId));
      return count;
    } catch (error, stackTrace) {
      if (ref.mounted) {
        _fail(sessionId, error, stackTrace, () => resetSession(sessionId));
      }
      return null;
    }
  }

  /// Runs the last failed action again.
  Future<void> retry() async {
    final action = _retry;
    _retry = null;
    failedSessionId = null;
    state = const AsyncData(null);
    if (action != null) await action();
  }

  // A session from another day would put the mark on a roster that is not on screen.
  bool _belongsToDay(String sessionId) {
    final sessions = ref.read(daySessionsProvider(date)).value;
    final belongs =
        sessions != null && sessions.any((session) => session.id == sessionId);
    assert(belongs, 'Session $sessionId is not one of the sessions on $date');
    return belongs;
  }

  void _replace(String sessionId, RosterEntry entry) =>
      ref.read(rosterProvider(sessionId).notifier).replace(entry);

  void _fail(
    String sessionId,
    Object error,
    StackTrace stackTrace,
    Future<void> Function() retry,
  ) {
    _retry = retry;
    failedSessionId = sessionId;
    final failure = error is AppException ? error : const UnknownException();
    state = AsyncError(failure, stackTrace);
  }
}

/// The add-extra-session sheet's submit; checks the times as the server does first.
class AddExtraSessionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns true once the session exists; it then becomes the selected session.
  Future<bool> submit(DateTime date, TimeOfDay? start, TimeOfDay? end) async {
    if (state.isLoading) return false;
    final invalid = _checkTimes(start, end);
    if (invalid != null) {
      state = AsyncError(invalid, StackTrace.current);
      return false;
    }
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(attendanceRepositoryProvider)
          .addExtraSession(date, start!, end!);
      if (!ref.mounted) return true;
      state = const AsyncData(null);
      ref.invalidate(daySessionsProvider(date));
      ref.read(selectedSessionIdProvider(date).notifier).select(session.id);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      final failure = error is AppException ? error : const UnknownException();
      state = AsyncError(failure, stackTrace);
      return false;
    }
  }
}

/// Removes an extra session; the server refuses one that already has attendance.
class DeleteExtraSessionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    // A failure belongs to the session it was about; another choice clears it.
    ref.watch(selectedSessionIdProvider(ref.watch(selectedDateProvider)));
    return const AsyncData(null);
  }

  Future<void> delete(
    ClubSession session,
    List<ClubSession> daySessions,
  ) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      await ref
          .read(attendanceRepositoryProvider)
          .deleteExtraSession(session.id);
      if (!ref.mounted) return;
      state = const AsyncData(null);
      final remaining = [
        for (final other in daySessions)
          if (other.id != session.id) other,
      ];
      final next = defaultSessionIdFor(remaining, ref.read(clockProvider)());
      ref.invalidate(daySessionsProvider(session.sessionDate));
      // Chosen before the reload lands, so the removed session's roster is never asked for.
      // Last call here: the new choice rebuilds this controller.
      ref
          .read(selectedSessionIdProvider(session.sessionDate).notifier)
          .select(next);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      final failure = error is AppException ? error : const UnknownException();
      state = AsyncError(failure, stackTrace);
    }
  }
}

ValidationException? _checkTimes(TimeOfDay? start, TimeOfDay? end) {
  if (start == null || end == null) {
    return const ValidationException('Choose a start and an end time');
  }
  if (_minutesOf(end) <= _minutesOf(start)) {
    return const ValidationException('End time must be after the start time');
  }
  return null;
}

int _minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;
