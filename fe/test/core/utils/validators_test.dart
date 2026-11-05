import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/utils/validators.dart';

void main() {
  group('requiredText', () {
    test('fails on null and blank', () {
      expect(requiredText(null), isNotNull);
      expect(requiredText('   '), isNotNull);
    });

    test('names the label in the message', () {
      expect(requiredText('', label: 'your name'), 'Enter your name');
    });

    test('passes on text', () {
      expect(requiredText('Asha'), isNull);
    });
  });

  group('phoneText', () {
    test('passes a valid 10-digit number', () {
      expect(phoneText('9876543210'), isNull);
    });

    test('fails with the fixed message on a short number', () {
      expect(phoneText('123'), 'Enter a 10-digit mobile number');
    });

    test('fails on null', () {
      expect(phoneText(null), 'Enter a 10-digit mobile number');
    });
  });

  group('passwordText', () {
    test('fails below 8 characters', () {
      expect(passwordText('1234567'), isNotNull);
    });

    test('passes at 8 characters', () {
      expect(passwordText('12345678'), isNull);
    });

    test('passes at 72 characters', () {
      expect(passwordText('a' * 72), isNull);
    });

    test('fails above 72 bytes', () {
      expect(passwordText('a' * 73), isNotNull);
    });

    test('fails when multibyte characters exceed 72 bytes', () {
      expect(passwordText('é' * 40), isNotNull);
    });

    test('fails on null', () {
      expect(passwordText(null), isNotNull);
    });
  });
}
