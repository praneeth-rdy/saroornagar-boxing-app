import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../../../support/fixtures/sessions.dart';
import '../../../support/mocks/mock_attendance_repository.dart';
import '../../../support/scenario.dart';

ProviderContainer _container(
  MockAttendanceRepository repository,
  DateTime indiaClock,
) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      attendanceRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => indiaClock),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final morningId = morningSession(fixtureDay).id;
  final eveningId = eveningSession(fixtureDay).id;

  group('defaultSessionIdFor', () {
    final sessions = [morningSession(fixtureDay), eveningSession(fixtureDay)];

    test('picks the first session that has not ended', () {
      expect(
        defaultSessionIdFor(sessions, DateTime.utc(2026, 11, 5, 7)),
        morningId,
      );
      expect(
        defaultSessionIdFor(sessions, DateTime.utc(2026, 11, 5, 9)),
        eveningId,
      );
    });

    test('picks the last session once the day is over', () {
      expect(
        defaultSessionIdFor(sessions, DateTime.utc(2026, 11, 5, 21)),
        eveningId,
      );
    });

    test('is null for an empty day', () {
      expect(defaultSessionIdFor(const [], DateTime.utc(2026, 11, 5)), isNull);
    });
  });

  test('the selected date starts at today in India time', () {
    final container = _container(
      MockAttendanceRepository(),
      DateTime.utc(2026, 11, 5, 7),
    );
    expect(container.read(selectedDateProvider), fixtureDay);
  });

  test('the selected session defaults by the clock', () async {
    final container = _container(
      MockAttendanceRepository(),
      DateTime.utc(2026, 11, 5, 9),
    );
    container.listen(selectedSessionIdProvider(fixtureDay), (_, _) {});
    await container.read(daySessionsProvider(fixtureDay).future);
    expect(container.read(selectedSessionIdProvider(fixtureDay)), eveningId);
  });

  test(
    'the selection for another day never holds a session of today',
    () async {
      final previousDay = DateTime(2026, 11, 4);
      final container = _container(
        MockAttendanceRepository(),
        DateTime.utc(2026, 11, 5, 16, 45),
      );
      container.listen(selectedSessionIdProvider(fixtureDay), (_, _) {});
      await container.read(daySessionsProvider(fixtureDay).future);
      container
          .read(selectedSessionIdProvider(fixtureDay).notifier)
          .select(morningId);
      final seen = <String?>[];
      container.listen(
        selectedSessionIdProvider(previousDay),
        (_, next) => seen.add(next),
        fireImmediately: true,
      );
      await container.read(daySessionsProvider(previousDay).future);

      expect(
        container.read(selectedSessionIdProvider(previousDay)),
        eveningSession(previousDay).id,
      );
      expect(seen.first, isNull);
      expect(seen, everyElement(isNot(anyOf(morningId, eveningId))));
      expect(container.read(selectedSessionIdProvider(fixtureDay)), morningId);
    },
  );

  test('a mark for a session of another day is refused', () async {
    final repository = MockAttendanceRepository();
    final container = _container(repository, DateTime.utc(2026, 11, 5, 7));
    container.listen(daySessionsProvider(fixtureDay), (_, _) {});
    await container.read(daySessionsProvider(fixtureDay).future);
    container.listen(markControllerProvider(fixtureDay), (_, _) {});
    final otherDayId = eveningSession(DateTime(2026, 11, 4)).id;

    await expectLater(
      container
          .read(markControllerProvider(fixtureDay).notifier)
          .mark(otherDayId, 'trainee-001'),
      throwsA(isA<AssertionError>()),
    );
    expect(repository.markCalls, isEmpty);
  });

  test('a failed mark is rolled back and can be retried', () async {
    final repository = MockAttendanceRepository();
    final container = _container(repository, DateTime.utc(2026, 11, 5, 7));
    container.listen(daySessionsProvider(fixtureDay), (_, _) {});
    await container.read(daySessionsProvider(fixtureDay).future);
    container.listen(rosterProvider(morningId), (_, _) {});
    await container.read(rosterProvider(morningId).future);
    container.listen(markControllerProvider(fixtureDay), (_, _) {});

    repository.scenario = MockScenario.offline;
    final controller = container.read(
      markControllerProvider(fixtureDay).notifier,
    );
    await controller.mark(morningId, 'trainee-001');

    final entries = container.read(rosterProvider(morningId)).value!;
    expect(
      entries.firstWhere((e) => e.traineeId == 'trainee-001').status,
      null,
    );
    expect(container.read(markControllerProvider(fixtureDay)).hasError, isTrue);
    expect(controller.failedSessionId, morningId);

    repository.scenario = MockScenario.success;
    await controller.retry();
    final after = container.read(rosterProvider(morningId)).value!;
    expect(
      after.firstWhere((e) => e.traineeId == 'trainee-001').status,
      AttendanceStatus.present,
    );
  });

  test('a failed unmark puts the present mark back', () async {
    final repository = MockAttendanceRepository();
    final container = _container(repository, DateTime.utc(2026, 11, 5, 7));
    container.listen(daySessionsProvider(fixtureDay), (_, _) {});
    await container.read(daySessionsProvider(fixtureDay).future);
    await repository.mark(morningId, 'trainee-001', AttendanceStatus.present);
    container.listen(rosterProvider(morningId), (_, _) {});
    await container.read(rosterProvider(morningId).future);
    container.listen(markControllerProvider(fixtureDay), (_, _) {});

    repository.scenario = MockScenario.offline;
    final controller = container.read(
      markControllerProvider(fixtureDay).notifier,
    );
    await controller.unmark(morningId, 'trainee-001');

    final entries = container.read(rosterProvider(morningId)).value!;
    expect(
      entries.firstWhere((e) => e.traineeId == 'trainee-001').status,
      AttendanceStatus.present,
    );
    expect(container.read(markControllerProvider(fixtureDay)).hasError, isTrue);
    expect(repository.markFor(morningId, 'trainee-001'), isNotNull);
  });
}
