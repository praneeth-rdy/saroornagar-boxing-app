import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainee_input.freezed.dart';

/// The editable fields of a trainee, sent whole to `create_trainee` and `update_trainee`.
@freezed
abstract class TraineeInput with _$TraineeInput {
  const factory TraineeInput({
    required int rollNo,
    required String fullName,
    String? phone,
    DateTime? dateOfBirth,
    DateTime? joinedOn,
    String? notes,
  }) = _TraineeInput;
}
