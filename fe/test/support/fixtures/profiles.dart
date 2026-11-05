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
