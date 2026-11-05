import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee_input.dart';

import '../fixtures/trainees.dart';
import '../scenario.dart';
import 'mock_trainee_repository.dart';

final _now = DateTime.utc(2026, 11, 5, 7);

MockTraineeRepository _repository({MockScenario? scenario}) =>
    MockTraineeRepository(
      scenario: scenario ?? MockScenario.success,
      trainees: [detailTrainee, inactiveTraineeRow],
      now: () => _now,
    );

Matcher _validation(String message) => throwsA(
  isA<ValidationException>().having((e) => e.message, 'message', message),
);

void main() {
  group('create validation messages equal the backend notes', () {
    test('name length', () {
      expect(
        _repository().create(const TraineeInput(fullName: ' A ')),
        _validation('Enter a name between 2 and 80 characters'),
      );
      expect(
        _repository().create(TraineeInput(fullName: 'x' * 81)),
        _validation('Enter a name between 2 and 80 characters'),
      );
    });

    test('phone', () {
      expect(
        _repository().create(
          const TraineeInput(fullName: 'Asha', phone: '12345'),
        ),
        _validation('Enter a 10-digit mobile number'),
      );
    });

    test('date of birth in the future and before the floor', () {
      expect(
        _repository().create(
          TraineeInput(fullName: 'Asha', dateOfBirth: DateTime(2026, 11, 7)),
        ),
        _validation('Date of birth cannot be in the future'),
      );
      expect(
        _repository().create(
          TraineeInput(fullName: 'Asha', dateOfBirth: DateTime(1900)),
        ),
        _validation('Enter a valid date of birth'),
      );
    });

    test('joining date more than a day ahead', () {
      expect(
        _repository().create(
          TraineeInput(fullName: 'Asha', joinedOn: DateTime(2026, 11, 7)),
        ),
        _validation('Joining date cannot be in the future'),
      );
    });

    test('notes over 500 characters', () {
      expect(
        _repository().create(TraineeInput(fullName: 'Asha', notes: 'n' * 501)),
        _validation('Notes must be 500 characters or fewer'),
      );
    });
  });

  test(
    'create trims, normalizes the phone and turns blanks into null',
    () async {
      final repository = _repository();
      final created = await repository.create(
        const TraineeInput(
          fullName: '  Asha Rao ',
          phone: '98765 43210',
          notes: '   ',
        ),
      );
      expect(created.fullName, 'Asha Rao');
      expect(created.phone, '919876543210');
      expect(created.notes, isNull);
      expect(created.status, TraineeStatus.active);
      expect(repository.traineeFor(created.id), created);
    },
  );

  test('update replaces every field and keeps the status', () async {
    final repository = _repository();
    final updated = await repository.update(
      detailTrainee.id,
      const TraineeInput(fullName: 'Arjun R'),
    );
    expect(updated.fullName, 'Arjun R');
    expect(updated.phone, isNull);
    expect(updated.dateOfBirth, isNull);
    expect(updated.status, TraineeStatus.active);
  });

  test('list filters by status and orders by name', () async {
    final repository = _repository();
    final active = await repository.list(status: TraineeStatus.active);
    final inactive = await repository.list(status: TraineeStatus.inactive);
    expect(active.map((t) => t.id), [detailTrainee.id]);
    expect(inactive.map((t) => t.id), [inactiveTraineeRow.id]);
  });

  test('setStatus moves a trainee between the lists', () async {
    final repository = _repository();
    await repository.setStatus(detailTrainee.id, TraineeStatus.inactive);
    final inactive = await repository.list(status: TraineeStatus.inactive);
    expect(inactive.map((t) => t.id), contains(detailTrainee.id));
  });

  test('byId throws not found for an unknown trainee', () {
    expect(_repository().byId('missing'), throwsA(isA<NotFoundException>()));
  });

  test('uploadPhoto records the upload and sets a photo path', () async {
    final repository = _repository();
    final saved = await repository.uploadPhoto(
      detailTrainee.id,
      Uint8List.fromList([1, 2, 3]),
      'me.jpg',
    );
    expect(saved.photoPath, isNotNull);
    expect(repository.uploads.single.size, 3);
    final removed = await repository.removePhoto(detailTrainee.id);
    expect(removed.photoPath, isNull);
  });

  test('scenarios throw the matching exceptions', () {
    expect(
      _repository(scenario: MockScenario.permissionDenied)
          .list(status: TraineeStatus.active),
      throwsA(isA<PermissionException>()),
    );
    expect(
      _repository(scenario: MockScenario.offline).byId(detailTrainee.id),
      throwsA(isA<OfflineException>()),
    );
  });
}
