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

  test('the roster is by roll number, not by name', () async {
    final repository = MockAttendanceRepository(
      trainees: const [
        FixtureTrainee(id: 'a', rollNo: 3, fullName: 'Asha'),
        FixtureTrainee(id: 'z', rollNo: 1, fullName: 'Zoya'),
        FixtureTrainee(id: 'm', rollNo: 2, fullName: 'Meera'),
      ],
    );
    await repository.sessionsFor(fixtureDay);
    final roster = await repository.roster(morningId);
    expect(roster.map((entry) => entry.rollNo), [1, 2, 3]);
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

  test('unmark removes the stored mark', () async {
    final repository = MockAttendanceRepository();
    await repository.sessionsFor(fixtureDay);
    await repository.mark(morningId, 'trainee-001', AttendanceStatus.present);
    await repository.unmark(morningId, 'trainee-001');
    expect(repository.markFor(morningId, 'trainee-001'), isNull);
  });

  test('unmark throws NotFoundException when there is no mark', () async {
    final repository = MockAttendanceRepository();
    await repository.sessionsFor(fixtureDay);
    expect(
      repository.unmark(morningId, 'trainee-001'),
      throwsA(
        isA<NotFoundException>().having(
          (e) => e.message,
          'message',
          'No mark to remove',
        ),
      ),
    );
  });

  test('reset removes every mark of the session only', () async {
    final repository = MockAttendanceRepository();
    await repository.sessionsFor(fixtureDay);
    final eveningId = eveningSession(fixtureDay).id;
    await repository.mark(morningId, 'trainee-001', AttendanceStatus.present);
    await repository.mark(morningId, 'trainee-002', AttendanceStatus.present);
    await repository.mark(eveningId, 'trainee-001', AttendanceStatus.present);

    expect(await repository.resetSession(morningId), 2);
    expect(await repository.resetSession(morningId), 0);
    expect(repository.markFor(morningId, 'trainee-001'), isNull);
    expect(repository.markFor(eveningId, 'trainee-001'), isNotNull);
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
