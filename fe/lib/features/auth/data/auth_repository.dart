import '../domain/staff_profile.dart';

/// Staff sign-in and the signed-in profile; failures surface as `AppException`s.
abstract class AuthRepository {
  bool get hasSession;

  /// Emits on sign-in and sign-out.
  Stream<bool> get sessionChanges;

  /// [email] is trimmed and lower-cased before it is sent.
  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<StaffProfile> currentProfile();

  /// Emails a 6-digit recovery code; succeeds whether or not the account exists.
  Future<void> requestPasswordReset(String email);

  /// Verifies the recovery [code], which signs in, then sets [newPassword].
  Future<void> completePasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });
}
