import 'package:saroornagar_boxing/core/models/staff_role.dart';
import 'package:saroornagar_boxing/features/auth/domain/staff_profile.dart';

final _created = DateTime.utc(2026, 11, 5, 4);

final adminProfile = StaffProfile(
  id: '00000000-0000-4000-8000-000000000001',
  fullName: 'Ravi Kumar',
  phone: '919000000001',
  role: StaffRole.admin,
  isBlocked: false,
  createdAt: _created,
  updatedAt: _created,
);

final coachProfile = StaffProfile(
  id: '00000000-0000-4000-8000-000000000002',
  fullName: 'Sana Begum',
  phone: '919000000002',
  role: StaffRole.coach,
  isBlocked: false,
  createdAt: _created,
  updatedAt: _created,
);

final blockedCoachProfile = StaffProfile(
  id: '00000000-0000-4000-8000-000000000003',
  fullName: 'Arjun Reddy',
  phone: '919000000003',
  role: StaffRole.coach,
  isBlocked: true,
  createdAt: _created,
  updatedAt: _created,
);

/// The ids [fixtureStaff] hands out, UUID-shaped like the server's.
String fixtureStaffId(int index) =>
    '00000000-0000-4000-8000-${(100 + index).toString().padLeft(12, '0')}';

const _staffNames = [
  'Imran Khan',
  'Lakshmi Devi',
  'Mohan Rao',
  'Nisha Patel',
  'Prakash Goud',
  'Rekha Sharma',
  'Suresh Yadav',
  'Tara Naidu',
  'Venkat Reddy',
  'Zoya Siddiqui',
  'Anil Varma',
  'Bhavana Iyer',
];

/// [count] extra staff after the admin: mostly coaches, every fourth an admin,
/// every third blocked.
List<StaffProfile> fixtureStaff(int count) => [
  for (var i = 0; i < count; i++)
    StaffProfile(
      id: fixtureStaffId(i),
      fullName: i < _staffNames.length
          ? _staffNames[i]
          : '${_staffNames[i % _staffNames.length]} ${i ~/ _staffNames.length + 1}',
      phone: '9198${(4000000 + i).toString().padLeft(8, '0')}',
      role: i % 4 == 3 ? StaffRole.admin : StaffRole.coach,
      isBlocked: i % 3 == 2,
      createdAt: _created,
      updatedAt: _created,
    ),
];

/// The admin, an active coach and a blocked coach.
final typicalStaff = [adminProfile, coachProfile, blockedCoachProfile];

/// Fifteen staff, blocked rows among them.
final heavyStaff = [adminProfile, coachProfile, ...fixtureStaff(13)];
