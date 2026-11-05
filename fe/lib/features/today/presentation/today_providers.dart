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

final selectedSessionIdProvider =
    NotifierProvider.autoDispose<SelectedSessionId, String?>(
      SelectedSessionId.new,
    );

final rosterProvider = AsyncNotifierProvider.autoDispose
    .family<RosterNotifier, List<RosterEntry>, String>(RosterNotifier.new);

final dayTrialsProvider = FutureProvider.autoDispose
    .family<List<TrialBooking>, DateTime>(
      (ref, date) =>
          ref.watch(attendanceRepositoryProvider).trialsBetween(date, date),
    );

final markControllerProvider = AsyncNotifierProvider.autoDispose
    .family<MarkController, void, String>(MarkController.new);

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

/// The session on screen; falls back to the default whenever the choice is not in the day.
class SelectedSessionId extends Notifier<String?> {
  @override
  String? build() {
    final date = ref.watch(selectedDateProvider);
    final sessions = ref.watch(daySessionsProvider(date));
    final loaded = sessions.value;
    if (loaded == null) return null;
    final current = stateOrNull;
    // Keeps a choice made while the day reloads, such as a session just added.
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

/// Marks for one session: optimistic single marks, the bulk absent mark, and a retry.
///
/// Loading means the bulk mark is running; an error is the last failed action.
class MarkController extends AsyncNotifier<void> {
  MarkController(this.sessionId);

  final String sessionId;
  Future<void> Function()? _retry;

  @override
  FutureOr<void> build() {}

  Future<void> mark(String traineeId, AttendanceStatus status) async {
    final previous = ref
        .read(rosterProvider(sessionId).notifier)
        .entryFor(traineeId);
    if (previous == null || previous.status == status) return;
    _replace(previous.copyWith(status: status, markedAt: null));
    try {
      final stored = await ref
          .read(attendanceRepositoryProvider)
          .mark(sessionId, traineeId, status);
      if (!ref.mounted) return;
      _replace(
        previous.copyWith(status: stored.status, markedAt: stored.markedAt),
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      _replace(previous);
      _fail(error, stackTrace, () => mark(traineeId, status));
    }
  }

  /// Returns how many were marked, or null when it failed (the error is in state).
  Future<int?> markRemainingAbsent() async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final count = await ref
          .read(attendanceRepositoryProvider)
          .markRemainingAbsent(sessionId);
      if (!ref.mounted) return count;
      state = const AsyncData(null);
      ref.invalidate(rosterProvider(sessionId));
      return count;
    } catch (error, stackTrace) {
      if (ref.mounted) _fail(error, stackTrace, markRemainingAbsent);
      return null;
    }
  }

  /// Runs the last failed action again.
  Future<void> retry() async {
    final action = _retry;
    _retry = null;
    state = const AsyncData(null);
    if (action != null) await action();
  }

  void _replace(RosterEntry entry) =>
      ref.read(rosterProvider(sessionId).notifier).replace(entry);

  void _fail(
    Object error,
    StackTrace stackTrace,
    Future<void> Function() retry,
  ) {
    _retry = retry;
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
      ref.read(selectedSessionIdProvider.notifier).select(session.id);
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
    ref.watch(selectedSessionIdProvider);
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
      ref.read(selectedSessionIdProvider.notifier).select(next);
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
