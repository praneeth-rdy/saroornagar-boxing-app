import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';

import '../fixtures/roster.dart';
import '../fixtures/sessions.dart';
import 'mock_attendance_repository.dart';

void main() {
  final morningId = morningSession(fixtureDay).id;

  test('a weekday has a morning and an evening session', () async {
    final repository = MockAttendanceRepository();
    final sessions = await repository.sessionsFor(fixtureDay);
    expect(sessions.map((s) => s.slot), [
      SessionSlot.morning,
      SessionSlot.evening,
    ]);
  });

  test('a Sunday has no sessions until an extra is added', () async {
    final repository = MockAttendanceRepository();
    expect(await repository.sessionsFor(fixtureSunday), isEmpty);
    await repository.addExtraSession(
      fixtureSunday,
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
    );
    expect(await repository.sessionsFor(fixtureSunday), hasLength(1));
  });

  test('an extra session must end after it starts', () async {
    final repository = MockAttendanceRepository();
    expect(
      repository.addExtraSession(
        fixtureDay,
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 10, minute: 0),
      ),
      throwsA(isA<ValidationException>()),
    );
  });

  test('marking the same status again keeps the original mark', () async {
    var tick = 0;
    final repository = MockAttendanceRepository(
      now: () => DateTime.utc(2026, 11, 5, 1, tick++),
    );
    await repository.sessionsFor(fixtureDay);
    final first = await repository.mark(
      morningId,
      'trainee-001',
      AttendanceStatus.present,
    );
    final again = await repository.mark(
      morningId,
      'trainee-001',
      AttendanceStatus.present,
    );
    expect(again.markedAt, first.markedAt);

    final changed = await repository.mark(
      morningId,
      'trainee-001',
      AttendanceStatus.absent,
    );
    expect(changed.status, AttendanceStatus.absent);
    expect(changed.markedAt.isAfter(first.markedAt), isTrue);
  });

  test('an inactive trainee cannot be marked', () async {
    final repository = MockAttendanceRepository(
      trainees: [...typicalTrainees, inactiveTrainee],
    );
    await repository.sessionsFor(fixtureDay);
    expect(
      repository.mark(morningId, inactiveTrainee.id, AttendanceStatus.present),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'This trainee is inactive',
        ),
      ),
    );
  });

  test('mark remaining absent counts only unmarked active trainees', () async {
    final repository = MockAttendanceRepository(
      trainees: [...fixtureTrainees(5), inactiveTrainee],
    );
    await repository.sessionsFor(fixtureDay);
    await repository.mark(morningId, 'trainee-001', AttendanceStatus.present);
    expect(await repository.markRemainingAbsent(morningId), 4);
    expect(await repository.markRemainingAbsent(morningId), 0);
    expect(
      repository.markFor(morningId, 'trainee-001')!.status,
      AttendanceStatus.present,
    );
  });

  test('a session with attendance cannot be removed', () async {
    final repository = MockAttendanceRepository();
    final extra = await repository.addExtraSession(
      fixtureDay,
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 17, minute: 0),
    );
    await repository.mark(extra.id, 'trainee-001', AttendanceStatus.present);
    expect(
      repository.deleteExtraSession(extra.id),
      throwsA(isA<ValidationException>()),
    );
  });
}
