import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';
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
        _repository().create(const TraineeInput(rollNo: 1, fullName: ' A ')),
        _validation('Enter a name between 2 and 80 characters'),
      );
      expect(
        _repository().create(TraineeInput(rollNo: 1, fullName: 'x' * 81)),
        _validation('Enter a name between 2 and 80 characters'),
      );
    });

    test('phone', () {
      expect(
        _repository().create(
          const TraineeInput(rollNo: 1, fullName: 'Asha', phone: '12345'),
        ),
        _validation('Enter a 10-digit mobile number'),
      );
    });

    test('date of birth in the future and before the floor', () {
      expect(
        _repository().create(
          TraineeInput(
            rollNo: 1,
            fullName: 'Asha',
            dateOfBirth: DateTime(2026, 11, 7),
          ),
        ),
        _validation('Date of birth cannot be in the future'),
      );
      expect(
        _repository().create(
          TraineeInput(
            rollNo: 1,
            fullName: 'Asha',
            dateOfBirth: DateTime(1900),
          ),
        ),
        _validation('Enter a valid date of birth'),
      );
    });

    test('joining date more than a day ahead', () {
      expect(
        _repository().create(
          TraineeInput(
            rollNo: 1,
            fullName: 'Asha',
            joinedOn: DateTime(2026, 11, 7),
          ),
        ),
        _validation('Joining date cannot be in the future'),
      );
    });

    test('notes over 500 characters', () {
      expect(
        _repository().create(
          TraineeInput(rollNo: 1, fullName: 'Asha', notes: 'n' * 501),
        ),
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
          rollNo: 1,
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
      const TraineeInput(rollNo: 12, fullName: 'Arjun R'),
    );
    expect(updated.fullName, 'Arjun R');
    expect(updated.phone, isNull);
    expect(updated.dateOfBirth, isNull);
    expect(updated.status, TraineeStatus.active);
  });

  test('list filters by status', () async {
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

  group('roll numbers', () {
    Trainee row(String id, int rollNo, {bool isActive = true}) =>
        detailTrainee.copyWith(
          id: id,
          rollNo: rollNo,
          status: isActive ? TraineeStatus.active : TraineeStatus.inactive,
        );

    test('nextRollNo suggests the lowest free number first', () async {
      final repository = MockTraineeRepository(
        trainees: [row('a', 1), row('b', 3), row('c', 2, isActive: false)],
      );
      expect(await repository.nextRollNo(), 2);
    });

    test('nextRollNo is the highest plus one without a gap', () async {
      final repository = MockTraineeRepository(
        trainees: [row('a', 1), row('b', 2)],
      );
      expect(await repository.nextRollNo(), 3);
    });

    test('nextRollNo is 1 with no active students', () async {
      expect(await MockTraineeRepository().nextRollNo(), 1);
    });

    test('create refuses a number an active student has', () {
      expect(
        _repository().create(const TraineeInput(rollNo: 12, fullName: 'Asha')),
        throwsA(
          isA<DuplicateException>().having(
            (e) => e.message,
            'message',
            'Roll number 12 is already in use',
          ),
        ),
      );
    });

    test('create refuses 0 and negative numbers', () {
      expect(
        _repository().create(const TraineeInput(rollNo: 0, fullName: 'Asha')),
        _validation('Enter a roll number above 0'),
      );
    });

    test('create reuses an inactive student\'s number', () async {
      final created = await _repository().create(
        const TraineeInput(rollNo: 90, fullName: 'Asha'),
      );
      expect(created.rollNo, 90);
    });

    test('update can change the number', () async {
      final updated = await _repository().update(
        detailTrainee.id,
        const TraineeInput(rollNo: 5, fullName: 'Arjun Reddy'),
      );
      expect(updated.rollNo, 5);
    });

    test('reactivating onto a number in use is a duplicate', () async {
      final repository = _repository();
      await repository.update(
        detailTrainee.id,
        const TraineeInput(rollNo: 90, fullName: 'Arjun Reddy'),
      );
      expect(
        repository.setStatus(inactiveTraineeRow.id, TraineeStatus.active),
        throwsA(
          isA<DuplicateException>().having(
            (e) => e.message,
            'message',
            'Roll number 90 is already in use',
          ),
        ),
      );
    });

    test('list orders by roll number', () async {
      final repository = MockTraineeRepository(
        trainees: [
          row('a', 3).copyWith(fullName: 'Asha'),
          row('b', 1).copyWith(fullName: 'Zoya'),
          row('c', 2).copyWith(fullName: 'Meera'),
        ],
      );
      final active = await repository.list(status: TraineeStatus.active);
      expect(active.map((t) => t.rollNo), [1, 2, 3]);
    });
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

  test('replacing a photo deletes the previous object after saving', () async {
    final repository = _repository();
    final first = await repository.uploadPhoto(
      detailTrainee.id,
      Uint8List.fromList([1]),
      'a.jpg',
    );
    final second = await repository.uploadPhoto(
      detailTrainee.id,
      Uint8List.fromList([2]),
      'b.jpg',
    );
    expect(repository.deletedPhotoPaths, [first.photoPath]);
    expect(
      repository.traineeFor(detailTrainee.id)!.photoPath,
      second.photoPath,
    );
  });

  test('removing a photo deletes its object', () async {
    final repository = _repository();
    final saved = await repository.uploadPhoto(
      detailTrainee.id,
      Uint8List.fromList([1]),
      'a.jpg',
    );
    await repository.removePhoto(detailTrainee.id);
    expect(repository.deletedPhotoPaths, [saved.photoPath]);
  });

  test('history throws Student not found for an unknown student', () {
    expect(
      _repository().history(
        'missing',
        DateTime(2026, 11),
        DateTime(2026, 11, 5),
      ),
      throwsA(
        isA<NotFoundException>().having(
          (error) => error.message,
          'message',
          'Student not found',
        ),
      ),
    );
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
