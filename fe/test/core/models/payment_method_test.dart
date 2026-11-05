import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/payment_method.dart';

void main() {
  group('PaymentMethod', () {
    test('fromWire parses a known wire value', () {
      expect(PaymentMethod.fromWire('upi'), PaymentMethod.upi);
    });

    test('fromWire returns unknown for null', () {
      expect(PaymentMethod.fromWire(null), PaymentMethod.unknown);
    });

    test('fromWire returns unknown for an unmatched value', () {
      expect(PaymentMethod.fromWire('nonsense'), PaymentMethod.unknown);
    });

    test(
      'fromWire does not parse the literal unknown wire as a real value',
      () {
        expect(PaymentMethod.fromWire('unknown'), PaymentMethod.unknown);
      },
    );

    test('wire round trips for every real value', () {
      for (final item in PaymentMethod.values.where(
        (item) => item != PaymentMethod.unknown,
      )) {
        expect(PaymentMethod.fromWire(item.wire), item);
      }
    });
  });
}
