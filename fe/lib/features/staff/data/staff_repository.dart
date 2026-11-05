import '../../../core/models/staff_role.dart';
import '../../auth/domain/staff_profile.dart';

/// The club's staff accounts, managed by an admin; failures surface as `AppException`s.
abstract class StaffRepository {
  /// Every staff member, by name.
  Future<List<StaffProfile>> list();

  /// Creates the sign-in account and its profile through the `admin-staff` function.
  Future<StaffProfile> create({
    required String fullName,
    required String email,
    required String password,
    required StaffRole role,
    String? phone,
  });

  /// Sets a staff member's name, role and phone (`update_staff`); a null phone clears it.
  Future<StaffProfile> update(
    String userId, {
    required String fullName,
    required StaffRole role,
    String? phone,
  });

  Future<void> resetPassword(String userId, String password);

  /// Blocks or unblocks sign-in and every server call for [userId].
  Future<StaffProfile> setBlocked(String userId, bool blocked);
}
