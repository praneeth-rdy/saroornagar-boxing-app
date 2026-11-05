import 'dart:convert';

import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/staff_role.dart';
import 'package:saroornagar_boxing/core/utils/phone_format.dart';
import 'package:saroornagar_boxing/core/utils/validators.dart';
import 'package:saroornagar_boxing/features/auth/domain/staff_profile.dart';
import 'package:saroornagar_boxing/features/staff/data/staff_repository.dart';

import '../fixtures/profiles.dart';
import '../scenario.dart';

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// In-memory [StaffRepository] that follows `update_staff`
/// (`20261105105121_email_sign_in`) and the `admin-staff` Edge Function: same order of
/// checks, same messages. [caller] is the signed-in staff member.
class MockStaffRepository implements StaffRepository {
  MockStaffRepository({
    this.scenario = MockScenario.success,
    List<StaffProfile>? staff,
    StaffProfile? caller,
  }) : caller = caller ?? adminProfile {
    for (final member in staff ?? typicalStaff) {
      _staff[member.id] = member;
    }
  }

  MockScenario scenario;
  StaffProfile caller;

  final _staff = <String, StaffProfile>{};

  /// The last password set for each user id, for assertions.
  final passwords = <String, String>{};
  var _created = 0;

  /// Every stored profile by name, for assertions.
  List<StaffProfile> get stored => _sorted(_staff.values);

  StaffProfile? memberFor(String userId) => _staff[userId];

  @override
  Future<List<StaffProfile>> list() => applyScenario(
    scenario,
    success: () {
      // RLS: a blocked caller reads only their own row.
      final self = _staff[caller.id];
      if (self != null && self.isBlocked) return [self];
      return stored;
    },
    empty: () => const [],
  );

  @override
  Future<StaffProfile> create({
    required String fullName,
    required String email,
    required String password,
    required StaffRole role,
    String? phone,
  }) => applyScenario(
    scenario,
    success: () {
      _requireAdmin();
      final name = _requireFullName(fullName);
      final normalizedEmail = _requireEmail(email);
      final normalizedPhone = _optionalPhone(phone);
      _requirePassword(password);
      if (role != StaffRole.admin && role != StaffRole.coach) {
        throw const ValidationException('Choose a role');
      }
      // The function checks the phone before Auth reports a taken email.
      if (normalizedPhone != null && _phoneOwner(normalizedPhone) != null) {
        throw const DuplicateException(_phoneClash);
      }
      if (_staff.values.any((member) => member.email == normalizedEmail)) {
        throw const DuplicateException(
          'A staff member with this email already exists',
        );
      }
      final now = DateTime.now().toUtc();
      final created = StaffProfile(
        id: fixtureStaffId(900 + _created++),
        fullName: name,
        email: normalizedEmail,
        phone: normalizedPhone,
        role: role,
        isBlocked: false,
        createdAt: now,
        updatedAt: now,
      );
      _staff[created.id] = created;
      passwords[created.id] = password;
      return created;
    },
  );

  @override
  Future<StaffProfile> update(
    String userId, {
    required String fullName,
    required StaffRole role,
    String? phone,
  }) => applyScenario(
    scenario,
    success: () {
      final self = _staff[caller.id] ?? caller;
      if (!self.isAdmin || self.isBlocked) {
        throw const PermissionException('Only an admin can edit staff');
      }
      final member = _staff[userId];
      if (member == null) {
        throw const NotFoundException('Staff member not found');
      }
      final newRole = role == StaffRole.unknown ? null : role;
      if (userId == caller.id && newRole != member.role) {
        throw const ValidationException('You cannot change your own role');
      }
      final name = fullName.trim();
      final length = name.runes.length;
      if (length < 2 || length > 80) {
        throw const ValidationException(
          'Enter a name between 2 and 80 characters',
        );
      }
      if (newRole == null) throw const ValidationException('Choose a role');
      final newPhone = _optionalPhone(phone);
      final owner = newPhone == null ? null : _phoneOwner(newPhone);
      if (owner != null && owner.id != userId) {
        throw const DuplicateException(_phoneClash);
      }
      return _store(
        member.copyWith(fullName: name, role: newRole, phone: newPhone),
      );
    },
  );

  @override
  Future<void> resetPassword(String userId, String password) => applyScenario(
    scenario,
    success: () {
      _requireAdmin();
      _requireUserId(userId);
      _requirePassword(password);
      _requireMember(userId);
      passwords[userId] = password;
    },
  );

  @override
  Future<StaffProfile> setBlocked(String userId, bool blocked) => applyScenario(
    scenario,
    success: () {
      _requireAdmin();
      _requireUserId(userId);
      final member = _requireMember(userId);
      if (userId == caller.id) {
        throw const ValidationException('You cannot block yourself');
      }
      return _store(member.copyWith(isBlocked: blocked));
    },
  );

  void _requireAdmin() {
    final self = _staff[caller.id] ?? caller;
    if (!self.isAdmin || self.isBlocked) {
      throw const PermissionException('Only an admin can manage staff');
    }
  }

  StaffProfile? _phoneOwner(String phone) {
    for (final member in _staff.values) {
      if (member.phone == phone) return member;
    }
    return null;
  }

  StaffProfile _requireMember(String userId) {
    final member = _staff[userId];
    if (member == null) throw const NotFoundException('Staff member not found');
    return member;
  }

  StaffProfile _store(StaffProfile member) {
    final updated = member.copyWith(updatedAt: DateTime.now().toUtc());
    _staff[updated.id] = updated;
    return updated;
  }
}

const _phoneClash = 'This number belongs to another staff member';

String _requireEmail(String value) {
  if (emailText(value) != null) {
    throw const ValidationException('Enter a valid email address');
  }
  return normalizeEmail(value);
}

// Null or blank means no phone, as the function and update_staff treat it.
String? _optionalPhone(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = normalizePhone(value);
  if (normalized == null) {
    throw const ValidationException('Enter a 10-digit mobile number');
  }
  return normalized;
}

String _requireFullName(String value) {
  final name = value.trim();
  final length = name.runes.length;
  if (length < 2 || length > 80) {
    throw const ValidationException('Enter a name between 2 and 80 characters');
  }
  return name;
}

// Auth hashes with bcrypt, which reads at most 72 bytes.
void _requirePassword(String value) {
  if (value.runes.length < 8 || utf8.encode(value).length > 72) {
    throw const ValidationException('Enter a password of 8 to 72 characters');
  }
}

void _requireUserId(String value) {
  if (!_uuidPattern.hasMatch(value)) {
    throw const ValidationException('Choose a staff member');
  }
}

List<StaffProfile> _sorted(Iterable<StaffProfile> staff) => staff.toList()
  ..sort(
    (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
  );
