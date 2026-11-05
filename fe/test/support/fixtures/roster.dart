import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/features/today/domain/attendance_mark.dart';

import 'profiles.dart';

/// A trainee as the mock attendance repository stores it.
class FixtureTrainee {
  const FixtureTrainee({
    required this.id,
    required this.fullName,
    this.photoPath,
    this.isActive = true,
  });

  final String id;
  final String fullName;
  final String? photoPath;
  final bool isActive;
}

const _firstNames = [
  'Arjun',
  'Sana',
  'Vikram',
  'Meera',
  'Rohit',
  'Ayesha',
  'Karthik',
  'Divya',
  'Imran',
  'Lakshmi',
  'Naveen',
  'Pooja',
  'Rahul',
  'Shreya',
  'Tarun',
  'Usha',
  'Varun',
  'Zoya',
  'Harish',
  'Nikita',
];

const _lastNames = [
  'Reddy',
  'Khan',
  'Thakur',
  'Sharma',
  'Bose',
  'Mirza',
  'Rao',
  'Iyer',
  'Shaikh',
  'Naidu',
  'Goud',
  'Varma',
  'Patel',
  'Joshi',
  'Yadav',
  'Menon',
  'Chowdary',
  'Ali',
  'Kumar',
  'Das',
];

/// [count] active trainees with unique names, ids `trainee-001` upwards.
List<FixtureTrainee> fixtureTrainees(int count) => [
  for (var i = 0; i < count; i++)
    FixtureTrainee(
      id: 'trainee-${(i + 1).toString().padLeft(3, '0')}',
      fullName:
          '${_firstNames[i % _firstNames.length]} '
          '${_lastNames[(i + i ~/ _firstNames.length) % _lastNames.length]}',
    ),
];

/// The typical roster of the proofs: 20 active trainees.
final typicalTrainees = fixtureTrainees(20);

/// The heavy roster of the proofs: 60 active trainees.
final heavyTrainees = fixtureTrainees(60);

/// Off the roster; marking them fails like the server does.
const inactiveTrainee = FixtureTrainee(
  id: 'trainee-inactive',
  fullName: 'Kiran Rao',
  isActive: false,
);

/// The first India morning mark, 6:02 am on the fixture day, as a UTC instant.
final fixtureMarkTime = DateTime.utc(2026, 11, 5, 0, 32);

/// Marks the first [present] of [trainees] present and the next [absent] absent, a few
/// minutes apart from [fixtureMarkTime].
List<AttendanceMark> fixtureMarks(
  String sessionId,
  List<FixtureTrainee> trainees, {
  required int present,
  int absent = 0,
}) => [
  for (var i = 0; i < present + absent; i++)
    AttendanceMark(
      sessionId: sessionId,
      traineeId: trainees[i].id,
      status: i < present ? AttendanceStatus.present : AttendanceStatus.absent,
      markedBy: adminProfile.id,
      markedAt: fixtureMarkTime.add(Duration(minutes: i)),
    ),
];
