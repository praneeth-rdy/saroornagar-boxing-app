import 'dart:typed_data';

import '../../../core/models/trainee_status.dart';
import '../domain/attendance_record.dart';
import '../domain/trainee.dart';
import '../domain/trainee_input.dart';

/// The club's roster; failures surface as `AppException`s.
abstract class TraineeRepository {
  /// Trainees with [status], by name.
  Future<List<Trainee>> list({required TraineeStatus status});

  /// Throws `NotFoundException` when there is no such trainee.
  Future<Trainee> byId(String id);

  Future<Trainee> create(TraineeInput input);

  /// Replaces every editable field; a null field is cleared.
  Future<Trainee> update(String id, TraineeInput input);

  Future<Trainee> setStatus(String id, TraineeStatus status);

  /// Stores the photo under the trainee's folder and links it to the trainee.
  Future<Trainee> uploadPhoto(String id, Uint8List bytes, String fileName);

  /// Unlinks the photo; the stored object is left in place.
  Future<Trainee> removePhoto(String id);

  /// A short-lived URL for a stored photo, or null when there is none.
  Future<String?> photoUrl(String? photoPath);

  /// The trainee's marks for sessions dated [from] to [to], both inclusive, newest first.
  Future<List<AttendanceRecord>> history(String id, DateTime from, DateTime to);
}
