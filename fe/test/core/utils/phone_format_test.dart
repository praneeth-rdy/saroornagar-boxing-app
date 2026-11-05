import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/utils/phone_format.dart';

void main() {
  group('formatPhone', () {
    test('formats a 12-digit 91 number', () {
      expect(formatPhone('919876543210'), '+91 98765 43210');
    });

    test('returns other input as is', () {
      expect(formatPhone('12345'), '12345');
      expect(formatPhone('449876543210'), '449876543210');
    });
  });

  group('normalizePhone', () {
    test('adds 91 to a 10-digit number', () {
      expect(normalizePhone('9876543210'), '919876543210');
    });

    test('strips spaces and punctuation', () {
      expect(normalizePhone('+91 98765-43210'), '919876543210');
    });

    test('keeps a 12-digit 91 number', () {
      expect(normalizePhone('919876543210'), '919876543210');
    });

    test('returns null for too few digits', () {
      expect(normalizePhone('98765'), isNull);
    });

    test('returns null for 12 digits not starting with 91', () {
      expect(normalizePhone('449876543210'), isNull);
    });

    test('returns null for empty input', () {
      expect(normalizePhone(''), isNull);
    });
  });
}
