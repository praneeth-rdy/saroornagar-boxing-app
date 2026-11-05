import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/staff_role.dart';

part 'staff_profile.freezed.dart';
part 'staff_profile.g.dart';

/// The signed-in staff member's row from `public.profiles`.
@freezed
abstract class StaffProfile with _$StaffProfile {
  const StaffProfile._();

  const factory StaffProfile({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String phone,
    @JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire)
    required StaffRole role,
    @JsonKey(name: 'is_blocked') required bool isBlocked,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _StaffProfile;

  factory StaffProfile.fromJson(Map<String, dynamic> json) =>
      _$StaffProfileFromJson(json);

  bool get isAdmin => role == StaffRole.admin;
}

String _roleToWire(StaffRole role) => role.wire;
