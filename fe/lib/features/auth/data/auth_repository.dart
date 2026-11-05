import '../domain/staff_profile.dart';

/// Staff sign-in and the signed-in profile; failures surface as `AppException`s.
abstract class AuthRepository {
  bool get hasSession;

  /// Emits on sign-in and sign-out.
  Stream<bool> get sessionChanges;

  /// [phone] is the 10-digit mobile number as typed.
  Future<void> signIn({required String phone, required String password});

  Future<void> signOut();

  Future<StaffProfile> currentProfile();
}
