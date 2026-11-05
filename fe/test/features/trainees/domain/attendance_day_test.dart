import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_day.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_record.dart';

final _thursday = DateTime(2026, 11, 5);
final _wednesday = DateTime(2026, 11, 4);

AttendanceRecord _record(
  DateTime date,
  SessionSlot slot, {
  AttendanceStatus status = AttendanceStatus.present,
  String? startsAt,
}) => AttendanceRecord(
  sessionId: '${date.day}-${slot.wire}-$startsAt',
  sessionDate: date,
  slot: slot,
  status: status,
  markedAt: DateTime.utc(date.year, date.month, date.day, 1),
  startsAt: startsAt,
);

void main() {
  test(
    'present in both batches gives one day labelled morning and evening',
    () {
      final days = groupAttendanceByDate([
        _record(_thursday, SessionSlot.evening),
        _record(_thursday, SessionSlot.morning),
      ]);

      expect(days, [
        AttendanceDay(
          date: _thursday,
          slots: const [SessionSlot.morning, SessionSlot.evening],
        ),
      ]);
      expect(days.single.label, 'Morning and evening');
    },
  );

  test(
    'present in one batch and absent in the other shows that batch only',
    () {
      final days = groupAttendanceByDate([
        _record(_thursday, SessionSlot.evening),
        _record(
          _thursday,
          SessionSlot.morning,
          status: AttendanceStatus.absent,
        ),
      ]);

      expect(days.single.slots, [SessionSlot.evening]);
      expect(days.single.label, 'Evening');
    },
  );

  test('an extra session follows the regular batches', () {
    final days = groupAttendanceByDate([
      _record(_thursday, SessionSlot.extra),
      _record(_thursday, SessionSlot.morning),
    ]);

    expect(days.single.label, 'Morning and extra');
  });

  test('two extras beside both batches are counted', () {
    final days = groupAttendanceByDate([
      _record(_thursday, SessionSlot.extra),
      _record(_thursday, SessionSlot.morning),
      _record(_thursday, SessionSlot.extra),
      _record(_thursday, SessionSlot.evening),
    ]);

    expect(days.single.label, 'Morning, evening and 2 extras');
  });

  test('an extra with a start time is named by it', () {
    final days = groupAttendanceByDate([
      _record(_thursday, SessionSlot.extra, startsAt: '16:00:00'),
      _record(_thursday, SessionSlot.morning, startsAt: '06:00:00'),
    ]);

    expect(days.single.extraStarts, ['16:00:00']);
    expect(days.single.label, 'Morning and extra 4:00 pm');
  });

  test('two timed extras are named earliest first', () {
    final days = groupAttendanceByDate([
      _record(_thursday, SessionSlot.extra, startsAt: '16:00:00'),
      _record(_thursday, SessionSlot.evening, startsAt: '17:30:00'),
      _record(_thursday, SessionSlot.extra, startsAt: '07:15:00'),
    ]);

    expect(days.single.label, 'Evening, extra 7:15 am and extra 4:00 pm');
  });

  test('an absent extra is not named', () {
    final days = groupAttendanceByDate([
      _record(_thursday, SessionSlot.morning),
      _record(
        _thursday,
        SessionSlot.extra,
        status: AttendanceStatus.absent,
        startsAt: '16:00:00',
      ),
    ]);

    expect(days.single.label, 'Morning');
  });

  test('a date with only absent marks gives no day', () {
    final days = groupAttendanceByDate([
      _record(_thursday, SessionSlot.morning, status: AttendanceStatus.absent),
      _record(_thursday, SessionSlot.evening, status: AttendanceStatus.absent),
    ]);

    expect(days, isEmpty);
  });

  test('days come newest first', () {
    final days = groupAttendanceByDate([
      _record(_wednesday, SessionSlot.morning),
      _record(_thursday, SessionSlot.morning),
    ]);

    expect(days.map((day) => day.date), [_thursday, _wednesday]);
  });
}
