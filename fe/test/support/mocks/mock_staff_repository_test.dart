import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/staff_role.dart';
import 'package:saroornagar_boxing/features/auth/domain/staff_profile.dart';

import '../fixtures/profiles.dart';
import '../scenario.dart';
import 'mock_staff_repository.dart';

Future<void> _expectRejected<T extends AppException>(
  Future<Object?> call,
  String message,
) async {
  await expectLater(
    call,
    throwsA(isA<T>().having((error) => error.message, 'message', message)),
  );
}

Future<StaffProfile> _create(
  MockStaffRepository repository, {
  String fullName = 'New Coach',
  String email = 'asha@local.test',
  String? phone,
  String password = 'long-enough-1',
  StaffRole role = StaffRole.coach,
}) => repository.create(
  fullName: fullName,
  email: email,
  phone: phone,
  password: password,
  role: role,
);

void main() {
  group('create', () {
    test(
      'stores a trimmed, normalized member and remembers the password',
      () async {
        final repository = MockStaffRepository();

        final created = await _create(
          repository,
          fullName: '  Asha Rao  ',
          email: '  Asha@Local.Test ',
          phone: '9876500001',
        );

        expect(created.fullName, 'Asha Rao');
        expect(created.email, 'asha@local.test');
        expect(created.phone, '919876500001');
        expect(created.role, StaffRole.coach);
        expect(created.isBlocked, isFalse);
        expect(repository.passwords[created.id], 'long-enough-1');
        expect(
          (await repository.list()).map((m) => m.id),
          contains(created.id),
        );
      },
    );

    test('messages equal the function note', () async {
      final repository = MockStaffRepository();

      await _expectRejected<ValidationException>(
        _create(repository, fullName: 'A'),
        'Enter a name between 2 and 80 characters',
      );
      await _expectRejected<ValidationException>(
        _create(repository, fullName: 'a' * 81),
        'Enter a name between 2 and 80 characters',
      );
      await _expectRejected<ValidationException>(
        _create(repository, email: 'not-an-email'),
        'Enter a valid email address',
      );
      await _expectRejected<ValidationException>(
        _create(repository, phone: '12345'),
        'Enter a 10-digit mobile number',
      );
      await _expectRejected<ValidationException>(
        _create(repository, password: 'short'),
        'Enter a password of 8 to 72 characters',
      );
      await _expectRejected<ValidationException>(
        _create(repository, password: 'a' * 73),
        'Enter a password of 8 to 72 characters',
      );
      await _expectRejected<ValidationException>(
        _create(repository, role: StaffRole.unknown),
        'Choose a role',
      );
    });

    test('no phone is stored as null', () async {
      final repository = MockStaffRepository();

      final created = await _create(repository);
      final blank = await _create(
        repository,
        email: 'b@local.test',
        phone: ' ',
      );

      expect(created.phone, isNull);
      expect(blank.phone, isNull);
    });

    test('a duplicate phone is a DuplicateException', () async {
      final repository = MockStaffRepository();

      await _expectRejected<DuplicateException>(
        _create(repository, phone: '9000000001'),
        'This number belongs to another staff member',
      );
    });

    test('a duplicate email is a DuplicateException', () async {
      final repository = MockStaffRepository();

      await _expectRejected<DuplicateException>(
        _create(repository, email: ' COACH@local.test '),
        'A staff member with this email already exists',
      );
    });

    test('a coach caller is refused', () async {
      final repository = MockStaffRepository(caller: coachProfile);

      await _expectRejected<PermissionException>(
        _create(repository),
        'Only an admin can manage staff',
      );
    });
  });

  group('update', () {
    test('changes name and role of another member', () async {
      final repository = MockStaffRepository();

      final updated = await repository.update(
        coachProfile.id,
        fullName: ' Sana B ',
        role: StaffRole.admin,
      );

      expect(updated.fullName, 'Sana B');
      expect(updated.role, StaffRole.admin);
    });

    test('sets, replaces and clears the phone', () async {
      final repository = MockStaffRepository();

      final added = await repository.update(
        coachProfile.id,
        fullName: 'Sana Begum',
        role: StaffRole.coach,
        phone: '9876500002',
      );
      expect(added.phone, '919876500002');

      final cleared = await repository.update(
        coachProfile.id,
        fullName: 'Sana Begum',
        role: StaffRole.coach,
      );
      expect(cleared.phone, isNull);
      expect(repository.memberFor(coachProfile.id)!.phone, isNull);
    });

    test('a phone owned by someone else is a duplicate', () async {
      final repository = MockStaffRepository();

      await _expectRejected<DuplicateException>(
        repository.update(
          coachProfile.id,
          fullName: 'Sana Begum',
          role: StaffRole.coach,
          phone: '9000000001',
        ),
        'This number belongs to another staff member',
      );
      await _expectRejected<ValidationException>(
        repository.update(
          coachProfile.id,
          fullName: 'Sana Begum',
          role: StaffRole.coach,
          phone: '123',
        ),
        'Enter a 10-digit mobile number',
      );
    });

    test('keeping your own phone is not a duplicate', () async {
      final repository = MockStaffRepository();

      final updated = await repository.update(
        adminProfile.id,
        fullName: 'Ravi Kumar',
        role: StaffRole.admin,
        phone: '9000000001',
      );

      expect(updated.phone, '919000000001');
    });

    test('an admin cannot change their own role', () async {
      final repository = MockStaffRepository();

      await _expectRejected<ValidationException>(
        repository.update(
          adminProfile.id,
          fullName: 'Ravi Kumar',
          role: StaffRole.coach,
        ),
        'You cannot change your own role',
      );
    });

    test('an admin can rename themselves keeping the role', () async {
      final repository = MockStaffRepository();

      final updated = await repository.update(
        adminProfile.id,
        fullName: 'Ravi K',
        role: StaffRole.admin,
      );

      expect(updated.fullName, 'Ravi K');
    });

    test('unknown member and bad role are rejected', () async {
      final repository = MockStaffRepository();

      await _expectRejected<NotFoundException>(
        repository.update(
          fixtureStaffId(500),
          fullName: 'Someone',
          role: StaffRole.coach,
        ),
        'Staff member not found',
      );
      await _expectRejected<ValidationException>(
        repository.update(
          coachProfile.id,
          fullName: 'Sana',
          role: StaffRole.unknown,
        ),
        'Choose a role',
      );
    });

    test('a coach caller is refused', () async {
      final repository = MockStaffRepository(caller: coachProfile);

      await _expectRejected<PermissionException>(
        repository.update(
          coachProfile.id,
          fullName: 'Sana',
          role: StaffRole.coach,
        ),
        'Only an admin can edit staff',
      );
    });
  });

  group('resetPassword', () {
    test('stores the new password', () async {
      final repository = MockStaffRepository();

      await repository.resetPassword(coachProfile.id, 'brand-new-pass');

      expect(repository.passwords[coachProfile.id], 'brand-new-pass');
    });

    test('validates the password and the member', () async {
      final repository = MockStaffRepository();

      await _expectRejected<ValidationException>(
        repository.resetPassword(coachProfile.id, 'short'),
        'Enter a password of 8 to 72 characters',
      );
      await _expectRejected<ValidationException>(
        repository.resetPassword('not-a-uuid', 'long-enough-1'),
        'Choose a staff member',
      );
      await _expectRejected<NotFoundException>(
        repository.resetPassword(fixtureStaffId(500), 'long-enough-1'),
        'Staff member not found',
      );
    });
  });

  group('setBlocked', () {
    test('blocks and unblocks another member', () async {
      final repository = MockStaffRepository();

      final blocked = await repository.setBlocked(coachProfile.id, true);
      expect(blocked.isBlocked, isTrue);

      final restored = await repository.setBlocked(coachProfile.id, false);
      expect(restored.isBlocked, isFalse);
    });

    test('an admin cannot block themselves', () async {
      final repository = MockStaffRepository();

      await _expectRejected<ValidationException>(
        repository.setBlocked(adminProfile.id, true),
        'You cannot block yourself',
      );
    });

    test('a coach caller is refused', () async {
      final repository = MockStaffRepository(caller: coachProfile);

      await _expectRejected<PermissionException>(
        repository.setBlocked(blockedCoachProfile.id, false),
        'Only an admin can manage staff',
      );
    });
  });

  group('list', () {
    test('is ordered by name', () async {
      final repository = MockStaffRepository();

      final names = (await repository.list()).map((m) => m.fullName).toList();

      expect(names, [...names]..sort());
      expect(names, hasLength(3));
    });

    test('the empty scenario returns nothing', () async {
      final repository = MockStaffRepository(scenario: MockScenario.empty);

      expect(await repository.list(), isEmpty);
    });
  });
}
