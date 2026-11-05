import 'dart:typed_data';

import '../../../core/models/trainee_status.dart';
import '../domain/attendance_record.dart';
import '../domain/trainee.dart';
import '../domain/trainee_input.dart';

/// The club's roster; failures surface as `AppException`s.
abstract class TraineeRepository {
  /// Trainees with [status], by roll number, then name.
  Future<List<Trainee>> list({required TraineeStatus status});

  /// Throws `NotFoundException` when there is no such trainee.
  Future<Trainee> byId(String id);

  /// The suggested roll number for a new student: the lowest free among active students.
  Future<int> nextRollNo();

  /// Throws `DuplicateException` when an active student has the roll number.
  Future<Trainee> create(TraineeInput input);

  /// Replaces every editable field; a null field is cleared.
  Future<Trainee> update(String id, TraineeInput input);

  /// Throws `DuplicateException` when reactivating onto a roll number in use.
  Future<Trainee> setStatus(String id, TraineeStatus status);

  /// Stores the photo under the trainee's folder, links it, then deletes the old one (best effort).
  Future<Trainee> uploadPhoto(String id, Uint8List bytes, String fileName);

  /// Unlinks the photo, then deletes the stored object (best effort).
  Future<Trainee> removePhoto(String id);

  /// A short-lived URL for a stored photo, or null when there is none.
  Future<String?> photoUrl(String? photoPath);

  /// The trainee's marks for sessions dated [from] to [to], both inclusive, newest first.
  Future<List<AttendanceRecord>> history(String id, DateTime from, DateTime to);
}
