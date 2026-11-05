import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';

void main() {
  group('SessionSlot', () {
    test('fromWire parses a known wire value', () {
      expect(SessionSlot.fromWire('morning'), SessionSlot.morning);
    });

    test('fromWire returns unknown for null', () {
      expect(SessionSlot.fromWire(null), SessionSlot.unknown);
    });

    test('fromWire returns unknown for an unmatched value', () {
      expect(SessionSlot.fromWire('nonsense'), SessionSlot.unknown);
    });

    test(
      'fromWire does not parse the literal unknown wire as a real value',
      () {
        expect(SessionSlot.fromWire('unknown'), SessionSlot.unknown);
      },
    );

    test('wire round trips for every real value', () {
      for (final item in SessionSlot.values.where(
        (item) => item != SessionSlot.unknown,
      )) {
        expect(SessionSlot.fromWire(item.wire), item);
      }
    });

    test('label is the display name', () {
      expect(SessionSlot.morning.label, 'Morning');
      expect(SessionSlot.evening.label, 'Evening');
      expect(SessionSlot.extra.label, 'Extra');
    });
  });
}
