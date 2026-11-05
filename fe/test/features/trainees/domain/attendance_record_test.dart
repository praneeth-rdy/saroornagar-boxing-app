import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_record.dart';

Map<String, dynamic> _row({Object? startsAt, Object? endsAt}) => {
  'session_id': 's-1',
  'session_date': '2026-11-05',
  'slot': 'extra',
  'status': 'present',
  'marked_at': '2026-11-05T10:31:00+00:00',
  'starts_at': ?startsAt,
  'ends_at': ?endsAt,
};

void main() {
  test('fromJson reads the session start and end times', () {
    final record = AttendanceRecord.fromJson(
      _row(startsAt: '16:00:00', endsAt: '17:00:00'),
    );

    expect(record.slot, SessionSlot.extra);
    expect(record.startsAt, '16:00:00');
    expect(record.endsAt, '17:00:00');
  });

  test('fromJson leaves the times null when the row has none', () {
    final record = AttendanceRecord.fromJson(_row());

    expect(record.startsAt, isNull);
    expect(record.endsAt, isNull);
  });
}
