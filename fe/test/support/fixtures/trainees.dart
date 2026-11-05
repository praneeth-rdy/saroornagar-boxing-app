import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_record.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';

import 'roster.dart';
import 'sessions.dart';

final _created = DateTime.utc(2026, 1, 10, 4, 30);

/// [count] trainees with the roster fixture's ids and names; most have a phone and a
/// date of birth (ages 8 to 29 on the fixture day), every fourth has no phone and every
/// third no date of birth.
List<Trainee> fixtureTraineeRows(
  int count, {
  TraineeStatus status = TraineeStatus.active,
}) => [
  for (final (i, trainee) in fixtureTrainees(count).indexed)
    Trainee(
      id: trainee.id,
      fullName: trainee.fullName,
      phone: i % 4 == 3 ? null : '91987650${(1000 + i).toString()}',
      dateOfBirth: i % 3 == 2
          ? null
          : DateTime(2018 - (i % 22), 1 + i % 12, 10),
      joinedOn: DateTime(2026, 1 + i % 10, 1 + i % 28),
      status: status,
      createdAt: _created,
      updatedAt: _created,
    ),
];

/// The list proof's typical roster: 12 active trainees.
final typicalTraineeRows = fixtureTraineeRows(12);

/// The list proof's heavy roster: 80 active trainees.
final heavyTraineeRows = fixtureTraineeRows(80);

/// Only the name: no phone, date of birth, joining date or notes.
final bareTrainee = Trainee(
  id: 'trainee-bare',
  fullName: 'Kiran Rao',
  status: TraineeStatus.active,
  createdAt: _created,
  updatedAt: _created,
);

/// Every field set; 14 on the fixture day, so a junior.
final detailTrainee = Trainee(
  id: 'trainee-detail',
  fullName: 'Arjun Reddy',
  phone: '919876543210',
  dateOfBirth: DateTime(2012, 3, 14),
  joinedOn: DateTime(2026, 3, 3),
  status: TraineeStatus.active,
  notes: 'Southpaw. Working on footwork and keeping the guard up.',
  createdAt: _created,
  updatedAt: _created,
);

/// A long name and notes at the 500 character limit.
final longNotesTrainee = Trainee(
  id: 'trainee-long-notes',
  fullName: 'Venkata Satya Narayana Chowdary',
  phone: '919123456789',
  dateOfBirth: DateTime(1998, 7, 21),
  joinedOn: DateTime(2025, 6, 2),
  status: TraineeStatus.active,
  notes: List.filled(
    10,
    'Old shoulder injury, no heavy bag on Mondays. Call his brother first. ',
  ).join().substring(0, 500),
  createdAt: _created,
  updatedAt: _created,
);

/// Off the roster.
final inactiveTraineeRow = Trainee(
  id: 'trainee-inactive',
  fullName: 'Kiran Rao',
  phone: '919000011111',
  status: TraineeStatus.inactive,
  createdAt: _created,
  updatedAt: _created,
);

/// Morning marks on every non-Sunday of the [days] days up to [last], newest first;
/// every fifth is absent.
List<AttendanceRecord> fixtureAttendanceHistory({
  DateTime? last,
  int days = 60,
}) {
  final end = last ?? fixtureDay;
  final records = <AttendanceRecord>[];
  for (var offset = 0; offset < days; offset++) {
    final date = DateTime(end.year, end.month, end.day - offset);
    if (date.weekday == DateTime.sunday) continue;
    records.add(
      AttendanceRecord(
        sessionId: regularSessionId(date, SessionSlot.morning),
        sessionDate: date,
        slot: SessionSlot.morning,
        status: records.length % 5 == 4
            ? AttendanceStatus.absent
            : AttendanceStatus.present,
        markedAt: DateTime.utc(date.year, date.month, date.day, 0, 32),
      ),
    );
  }
  return records;
}
