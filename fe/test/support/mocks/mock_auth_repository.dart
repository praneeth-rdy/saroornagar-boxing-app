import 'dart:async';

import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/utils/phone_format.dart';
import 'package:saroornagar_boxing/features/auth/data/auth_repository.dart';
import 'package:saroornagar_boxing/features/auth/domain/staff_profile.dart';

import '../fixtures/profiles.dart';
import '../scenario.dart';

/// In-memory [AuthRepository] that checks one phone and password pair.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.scenario = MockScenario.success,
    StaffProfile? profile,
    bool signedIn = false,
    this.validPhone = '9000000001',
    this.validPassword = 'admin-local-1234',
  }) : profile = profile ?? adminProfile,
       isSignedIn = signedIn;

  MockScenario scenario;
  StaffProfile profile;
  final String validPhone;
  final String validPassword;
  bool isSignedIn;

  final _sessionChanges = StreamController<bool>.broadcast();

  @override
  bool get hasSession => isSignedIn;

  @override
  Stream<bool> get sessionChanges => _sessionChanges.stream;

  @override
  Future<void> signIn({required String phone, required String password}) async {
    final normalized = normalizePhone(phone);
    if (normalized == null) {
      throw const ValidationException('Enter a 10-digit mobile number');
    }
    await applyScenario<void>(scenario, success: () {});
    if (normalized != normalizePhone(validPhone) || password != validPassword) {
      throw const AuthFailedException();
    }
    isSignedIn = true;
    _sessionChanges.add(true);
  }

  @override
  Future<void> signOut() async {
    isSignedIn = false;
    _sessionChanges.add(false);
  }

  @override
  Future<StaffProfile> currentProfile() =>
      applyScenario(scenario, success: () => profile);

  Future<void> dispose() => _sessionChanges.close();
}
