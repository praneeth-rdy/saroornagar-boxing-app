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
    container.listen(selectedSessionIdProvider, (_, _) {});
    await container.read(daySessionsProvider(fixtureDay).future);
    expect(container.read(selectedSessionIdProvider), eveningId);
  });

  test('a failed mark is rolled back and can be retried', () async {
    final repository = MockAttendanceRepository();
    final container = _container(repository, DateTime.utc(2026, 11, 5, 7));
    await repository.sessionsFor(fixtureDay);
    container.listen(rosterProvider(morningId), (_, _) {});
    await container.read(rosterProvider(morningId).future);
    container.listen(markControllerProvider(morningId), (_, _) {});

    repository.scenario = MockScenario.offline;
    final controller = container.read(
      markControllerProvider(morningId).notifier,
    );
    await controller.mark('trainee-001', AttendanceStatus.present);

    final entries = container.read(rosterProvider(morningId)).value!;
    expect(
      entries.firstWhere((e) => e.traineeId == 'trainee-001').status,
      null,
    );
    expect(container.read(markControllerProvider(morningId)).hasError, isTrue);

    repository.scenario = MockScenario.success;
    await controller.retry();
    final after = container.read(rosterProvider(morningId)).value!;
    expect(
      after.firstWhere((e) => e.traineeId == 'trainee-001').status,
      AttendanceStatus.present,
    );
  });
}
