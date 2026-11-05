import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/staff_role.dart';
import '../../../core/supabase/supabase_errors.dart';
import '../../auth/domain/staff_profile.dart';
import 'staff_repository.dart';

const _adminFunction = 'admin-staff';

class SupabaseStaffRepository implements StaffRepository {
  SupabaseStaffRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<StaffProfile>> list() => guardSupabase(() async {
    final rows = await client.from('profiles').select().order('full_name');
    // Collation alone may not sort case-insensitively; the list reads by name.
    return rows.map(StaffProfile.fromJson).toList()..sort(_byName);
  });

  @override
  Future<StaffProfile> create({
    required String fullName,
    required String email,
    required String password,
    required StaffRole role,
    String? phone,
  }) => _profileFromFunction({
    'action': 'create',
    'full_name': fullName,
    'email': email,
    'password': password,
    // The function answers an unknown role with its own message.
    'role': role.wire,
    if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
  });

  @override
  Future<StaffProfile> update(
    String userId, {
    required String fullName,
    required StaffRole role,
    String? phone,
  }) => guardSupabase(() async {
    // A function returning one composite row comes back as a single JSON object.
    final row = await client.rpc<dynamic>(
      'update_staff',
      params: {
        'p_user_id': userId,
        'p_full_name': fullName,
        // An unknown role would fail the enum cast; null lets the server answer.
        'p_role': role == StaffRole.unknown ? null : role.wire,
        // Null or blank clears the phone on the server.
        'p_phone': phone,
      },
    );
    return StaffProfile.fromJson(Map<String, dynamic>.from(row as Map));
  });

  @override
  Future<void> resetPassword(String userId, String password) =>
      guardSupabase(() async {
        await client.functions.invoke(
          _adminFunction,
          body: {
            'action': 'reset_password',
            'user_id': userId,
            'password': password,
          },
        );
      });

  @override
  Future<StaffProfile> setBlocked(String userId, bool blocked) =>
      _profileFromFunction({
        'action': 'set_blocked',
        'user_id': userId,
        'blocked': blocked,
      });

  // A non-2xx answer throws a FunctionException carrying `{code, message}`.
  Future<StaffProfile> _profileFromFunction(Map<String, Object> body) =>
      guardSupabase(() async {
        final response = await client.functions.invoke(
          _adminFunction,
          body: body,
        );
        final data = Map<String, dynamic>.from(response.data as Map);
        return StaffProfile.fromJson(
          Map<String, dynamic>.from(data['profile'] as Map),
        );
      });
}

int _byName(StaffProfile a, StaffProfile b) =>
    a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
