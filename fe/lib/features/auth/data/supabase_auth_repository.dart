import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/supabase/supabase_errors.dart';
import '../../../core/utils/phone_format.dart';
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
  Future<void> signIn({required String phone, required String password}) async {
    final normalized = normalizePhone(phone);
    if (normalized == null) {
      throw const ValidationException('Enter a 10-digit mobile number');
    }
    await guardSupabase(
      () => client.auth.signInWithPassword(
        phone: '+$normalized',
        password: password,
      ),
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
}
