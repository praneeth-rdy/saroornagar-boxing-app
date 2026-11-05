import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/staff_role.dart';

part 'staff_input.freezed.dart';

/// The staff form's fields; [phone] and [password] are only sent when adding someone.
@freezed
abstract class StaffInput with _$StaffInput {
  const factory StaffInput({
    required String fullName,
    required StaffRole role,
    String? phone,
    String? password,
  }) = _StaffInput;
}
