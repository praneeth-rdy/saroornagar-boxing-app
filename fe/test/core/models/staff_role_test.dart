import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/staff_role.dart';

void main() {
  group('StaffRole', () {
    test('fromWire parses a known wire value', () {
      expect(StaffRole.fromWire('coach'), StaffRole.coach);
    });

    test('fromWire returns unknown for null', () {
      expect(StaffRole.fromWire(null), StaffRole.unknown);
    });

    test('fromWire returns unknown for an unmatched value', () {
      expect(StaffRole.fromWire('nonsense'), StaffRole.unknown);
    });

    test(
      'fromWire does not parse the literal unknown wire as a real value',
      () {
        expect(StaffRole.fromWire('unknown'), StaffRole.unknown);
      },
    );

    test('wire round trips for every real value', () {
      for (final item in StaffRole.values.where(
        (item) => item != StaffRole.unknown,
      )) {
        expect(StaffRole.fromWire(item.wire), item);
      }
    });
  });
}
