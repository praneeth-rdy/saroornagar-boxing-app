import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';

void main() {
  group('AttendanceStatus', () {
    test('fromWire parses a known wire value', () {
      expect(AttendanceStatus.fromWire('present'), AttendanceStatus.present);
    });

    test('fromWire returns unknown for null', () {
      expect(AttendanceStatus.fromWire(null), AttendanceStatus.unknown);
    });

    test('fromWire returns unknown for an unmatched value', () {
      expect(AttendanceStatus.fromWire('nonsense'), AttendanceStatus.unknown);
    });

    test(
      'fromWire does not parse the literal unknown wire as a real value',
      () {
        expect(AttendanceStatus.fromWire('unknown'), AttendanceStatus.unknown);
      },
    );

    test('wire round trips for every real value', () {
      for (final item in AttendanceStatus.values.where(
        (item) => item != AttendanceStatus.unknown,
      )) {
        expect(AttendanceStatus.fromWire(item.wire), item);
      }
    });
  });
}
