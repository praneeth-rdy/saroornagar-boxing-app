import 'dart:typed_data';

import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';
import 'package:saroornagar_boxing/core/utils/india_date.dart';
import 'package:saroornagar_boxing/core/utils/phone_format.dart';
import 'package:saroornagar_boxing/features/trainees/data/trainee_repository.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_record.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee_input.dart';

import '../scenario.dart';

/// One photo upload the mock received, for assertions.
typedef MockPhotoUpload = ({String traineeId, String fileName, int size});

/// In-memory [TraineeRepository] that follows the trainee migration's rules and messages
/// (`20261105075401_trainees_sessions`, `20261105080014_attendance_trials`).
class MockTraineeRepository implements TraineeRepository {
  MockTraineeRepository({
    this.scenario = MockScenario.success,
    List<Trainee> trainees = const [],
    Map<String, List<AttendanceRecord>> history = const {},
    DateTime Function()? now,
  }) : now = now ?? (() => DateTime.now().toUtc()) {
    for (final trainee in trainees) {
      _trainees[trainee.id] = trainee;
    }
    history.forEach((id, records) => _history[id] = [...records]);
  }

  MockScenario scenario;

  /// The instant stored as `created_at` and `updated_at`; its India date is "today".
  final DateTime Function() now;

  final _trainees = <String, Trainee>{};
  final _history = <String, List<AttendanceRecord>>{};
  var _createdCount = 0;
  var _photoCount = 0;

  /// Every photo upload, oldest first.
  final uploads = <MockPhotoUpload>[];

  /// The stored trainee, for assertions.
  Trainee? traineeFor(String id) => _trainees[id];

  @override
  Future<List<Trainee>> list({required TraineeStatus status}) => applyScenario(
    scenario,
    success: () =>
        _trainees.values.where((trainee) => trainee.status == status).toList()
          ..sort(_byName),
    empty: () => const [],
  );

  @override
  Future<Trainee> byId(String id) =>
      applyScenario(scenario, success: () => _trainee(id));

  @override
  Future<Trainee> create(TraineeInput input) => applyScenario(
    scenario,
    success: () {
      final clean = _clean(input);
      _createdCount++;
      final stamp = now();
      final trainee = Trainee(
        id: 'trainee-new-$_createdCount',
        fullName: clean.fullName,
        phone: clean.phone,
        dateOfBirth: input.dateOfBirth,
        joinedOn: input.joinedOn,
        status: TraineeStatus.active,
        notes: clean.notes,
        createdAt: stamp,
        updatedAt: stamp,
      );
      _trainees[trainee.id] = trainee;
      return trainee;
    },
  );

  @override
  Future<Trainee> update(String id, TraineeInput input) => applyScenario(
    scenario,
    success: () {
      final current = _trainee(id);
      final clean = _clean(input);
      return _store(
        current.copyWith(
          fullName: clean.fullName,
          phone: clean.phone,
          dateOfBirth: input.dateOfBirth,
          joinedOn: input.joinedOn,
          notes: clean.notes,
          updatedAt: now(),
        ),
      );
    },
  );

  @override
  Future<Trainee> setStatus(String id, TraineeStatus status) => applyScenario(
    scenario,
    success: () {
      final current = _trainee(id);
      if (status == TraineeStatus.unknown) {
        throw const ValidationException('Choose a status');
      }
      // The same status is a no-op, so updated_at only moves on a real change.
      if (current.status == status) return current;
      return _store(current.copyWith(status: status, updatedAt: now()));
    },
  );

  @override
  Future<Trainee> uploadPhoto(String id, Uint8List bytes, String fileName) =>
      applyScenario(
        scenario,
        success: () {
          final current = _trainee(id);
          _photoCount++;
          uploads.add((traineeId: id, fileName: fileName, size: bytes.length));
          return _store(
            current.copyWith(
              photoPath: '$id/photo-$_photoCount.jpg',
              updatedAt: now(),
            ),
          );
        },
      );

  @override
  Future<Trainee> removePhoto(String id) => applyScenario(
    scenario,
    success: () =>
        _store(_trainee(id).copyWith(photoPath: null, updatedAt: now())),
  );

  /// Always null: tests have no network, so avatars show initials.
  @override
  Future<String?> photoUrl(String? photoPath) async => null;

  @override
  Future<List<AttendanceRecord>> history(
    String id,
    DateTime from,
    DateTime to,
  ) => applyScenario(
    scenario,
    success: () {
      _trainee(id);
      final first = dateOnly(from);
      final last = dateOnly(to);
      if (last.isBefore(first)) {
        throw const ValidationException(
          'The end date is before the start date',
        );
      }
      return (_history[id] ?? const <AttendanceRecord>[])
          .where(
            (record) =>
                !record.sessionDate.isBefore(first) &&
                !record.sessionDate.isAfter(last),
          )
          .toList()
        ..sort(_newestFirst);
    },
    empty: () => const [],
  );

  Trainee _trainee(String id) {
    final trainee = _trainees[id];
    if (trainee == null) throw const NotFoundException('Trainee not found');
    return trainee;
  }

  Trainee _store(Trainee trainee) => _trainees[trainee.id] = trainee;

  // Mirrors private.clean_trainee_input: same checks, order and messages.
  ({String fullName, String? phone, String? notes}) _clean(TraineeInput input) {
    final today = dateOnly(toIndiaTime(now()));
    final fullName = input.fullName.trim();
    final nameLength = fullName.runes.length;
    if (nameLength < 2 || nameLength > 80) {
      throw const ValidationException(
        'Enter a name between 2 and 80 characters',
      );
    }
    final rawPhone = input.phone?.trim() ?? '';
    String? phone;
    if (rawPhone.isNotEmpty) {
      phone = normalizePhone(rawPhone);
      if (phone == null) {
        throw const ValidationException('Enter a 10-digit mobile number');
      }
    }
    final dateOfBirth = input.dateOfBirth;
    if (dateOfBirth != null) {
      if (dateOnly(dateOfBirth).isAfter(today)) {
        throw const ValidationException(
          'Date of birth cannot be in the future',
        );
      }
      if (!dateOnly(dateOfBirth).isAfter(DateTime(1900))) {
        throw const ValidationException('Enter a valid date of birth');
      }
    }
    final joinedOn = input.joinedOn;
    final latestJoin = DateTime(today.year, today.month, today.day + 1);
    if (joinedOn != null && dateOnly(joinedOn).isAfter(latestJoin)) {
      throw const ValidationException('Joining date cannot be in the future');
    }
    final trimmedNotes = input.notes?.trim() ?? '';
    final notes = trimmedNotes.isEmpty ? null : trimmedNotes;
    if (notes != null && notes.runes.length > 500) {
      throw const ValidationException('Notes must be 500 characters or fewer');
    }
    return (fullName: fullName, phone: phone, notes: notes);
  }
}

// Same order as the server: lower(full_name), then id.
int _byName(Trainee a, Trainee b) {
  final byName = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
  return byName != 0 ? byName : a.id.compareTo(b.id);
}

// Same order as the server: session date, then batch, newest first.
int _newestFirst(AttendanceRecord a, AttendanceRecord b) {
  final byDate = b.sessionDate.compareTo(a.sessionDate);
  return byDate != 0 ? byDate : b.slot.index.compareTo(a.slot.index);
}
