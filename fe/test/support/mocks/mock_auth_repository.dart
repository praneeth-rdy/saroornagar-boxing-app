import 'dart:async';

import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/utils/validators.dart';
import 'package:saroornagar_boxing/features/auth/data/auth_repository.dart';
import 'package:saroornagar_boxing/features/auth/domain/staff_profile.dart';

import '../fixtures/profiles.dart';
import '../scenario.dart';

/// The code [MockAuthRepository.requestPasswordReset] "emails".
const mockRecoveryCode = '123456';

/// In-memory [AuthRepository] that checks one email and password pair.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.scenario = MockScenario.success,
    StaffProfile? profile,
    bool signedIn = false,
    this.validEmail = 'admin@local.test',
    this.validPassword = 'admin-local-1234',
  }) : profile = profile ?? adminProfile,
       isSignedIn = signedIn;

  MockScenario scenario;
  StaffProfile profile;
  final String validEmail;

  /// Replaced by a completed password reset, as on the server.
  String validPassword;
  bool isSignedIn;

  /// Every address a reset code was requested for, normalized, in order.
  final resetRequests = <String>[];

  /// The code last "emailed"; null until a reset is requested.
  String? lastCode;

  final _sessionChanges = StreamController<bool>.broadcast();

  @override
  bool get hasSession => isSignedIn;

  @override
  Stream<bool> get sessionChanges => _sessionChanges.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    final normalized = _validEmail(email);
    await applyScenario<void>(scenario, success: () {});
    if (normalized != normalizeEmail(validEmail) || password != validPassword) {
      throw const AuthFailedException();
    }
    _setSignedIn();
  }

  @override
  Future<void> signOut() async {
    isSignedIn = false;
    _sessionChanges.add(false);
  }

  @override
  Future<StaffProfile> currentProfile() =>
      applyScenario(scenario, success: () => profile);

  @override
  Future<void> requestPasswordReset(String email) async {
    final normalized = _validEmail(email);
    await applyScenario<void>(scenario, success: () {});
    // Any address gets the same answer, so an unknown email is not revealed.
    resetRequests.add(normalized);
    lastCode = mockRecoveryCode;
  }

  @override
  Future<void> completePasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final normalized = _validEmail(email);
    await applyScenario<void>(scenario, success: () {});
    final isKnown =
        resetRequests.isNotEmpty && resetRequests.last == normalized;
    if (lastCode == null || code.trim() != lastCode || !isKnown) {
      throw const ValidationException('That code is wrong or has expired.');
    }
    validPassword = newPassword;
    lastCode = null;
    _setSignedIn();
  }

  void _setSignedIn() {
    isSignedIn = true;
    _sessionChanges.add(true);
  }

  Future<void> dispose() => _sessionChanges.close();
}

String _validEmail(String email) {
  final message = emailText(email);
  if (message != null) throw ValidationException(message);
  return normalizeEmail(email);
}
