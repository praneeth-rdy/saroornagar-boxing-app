import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/supabase/supabase_errors.dart';
import '../../../core/utils/validators.dart';
import '../domain/staff_profile.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this.client);

  final SupabaseClient client;

  @override
  bool get hasSession => client.auth.currentSession != null;

  @override
  Stream<bool> get sessionChanges => client.auth.onAuthStateChange
      .map((state) => state.session != null)
      .distinct();

  @override
  Future<void> signIn({required String email, required String password}) async {
    final normalized = _validEmail(email);
    await guardSupabase(
      () =>
          client.auth.signInWithPassword(email: normalized, password: password),
    );
  }

  @override
  Future<void> signOut() => guardSupabase(() => client.auth.signOut());

  @override
  Future<StaffProfile> currentProfile() => guardSupabase(() async {
    // A function returning one composite row comes back as a single JSON object.
    final row = await client.rpc<dynamic>('current_profile');
    return StaffProfile.fromJson(Map<String, dynamic>.from(row as Map));
  });

  @override
  Future<void> requestPasswordReset(String email) async {
    final normalized = _validEmail(email);
    await guardSupabase(() => client.auth.resetPasswordForEmail(normalized));
  }

  @override
  Future<void> completePasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final normalized = _validEmail(email);
    await guardSupabase(() async {
      await client.auth.verifyOTP(
        type: OtpType.recovery,
        email: normalized,
        token: code.trim(),
      );
      await client.auth.updateUser(UserAttributes(password: newPassword));
    });
  }
}

String _validEmail(String email) {
  final message = emailText(email);
  if (message != null) throw ValidationException(message);
  return normalizeEmail(email);
}
