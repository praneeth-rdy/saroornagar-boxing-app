import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/supabase/supabase_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeClientException implements Exception {
  @override
  String toString() => 'ClientException: Connection closed';
}

void main() {
  group('mapSupabaseError for Postgres codes', () {
    test('BXVAL maps to ValidationException with the server message', () {
      final result = mapSupabaseError(
        const PostgrestException(message: 'Name is required', code: 'BXVAL'),
      );

      expect(result, isA<ValidationException>());
      expect(result.message, 'Name is required');
    });

    test('BXPRM maps to PermissionException', () {
      final result = mapSupabaseError(
        const PostgrestException(message: 'Not yours', code: 'BXPRM'),
      );

      expect(result, isA<PermissionException>());
      expect(result.message, 'Not yours');
    });

    test('BXNTF maps to NotFoundException', () {
      final result = mapSupabaseError(
        const PostgrestException(message: 'No such trainee', code: 'BXNTF'),
      );

      expect(result, isA<NotFoundException>());
      expect(result.message, 'No such trainee');
    });

    test('BXDUP maps to DuplicateException', () {
      final result = mapSupabaseError(
        const PostgrestException(message: 'Already marked', code: 'BXDUP'),
      );

      expect(result, isA<DuplicateException>());
      expect(result.message, 'Already marked');
    });

    test('a blank server message falls back to the default message', () {
      final result = mapSupabaseError(
        const PostgrestException(message: ' ', code: 'BXDUP'),
      );

      expect(result.message, DuplicateException.defaultMessage);
    });

    test('42501 maps to PermissionException', () {
      final result = mapSupabaseError(
        const PostgrestException(message: 'denied', code: '42501'),
      );

      expect(result, isA<PermissionException>());
    });

    test('PGRST301 maps to PermissionException', () {
      final result = mapSupabaseError(
        const PostgrestException(message: 'jwt expired', code: 'PGRST301'),
      );

      expect(result, isA<PermissionException>());
    });

    test('an unlisted code maps to UnknownException', () {
      final result = mapSupabaseError(
        const PostgrestException(message: 'boom', code: '23505'),
      );

      expect(result, isA<UnknownException>());
    });
  });

  group('mapSupabaseError for Edge Function failures', () {
    test(
      'a details code BXVAL maps to ValidationException with its message',
      () {
        final result = mapSupabaseError(
          FunctionException(
            status: 400,
            details: {'code': 'BXVAL', 'message': 'Weak password'},
          ),
        );

        expect(result, isA<ValidationException>());
        expect(result.message, 'Weak password');
      },
    );

    test('a details code BXPRM maps to PermissionException', () {
      final result = mapSupabaseError(
        FunctionException(status: 403, details: {'code': 'BXPRM'}),
      );

      expect(result, isA<PermissionException>());
    });

    test('a details code BXNTF maps to NotFoundException', () {
      final result = mapSupabaseError(
        FunctionException(status: 404, details: {'code': 'BXNTF'}),
      );

      expect(result, isA<NotFoundException>());
    });

    test('a details code BXDUP maps to DuplicateException', () {
      final result = mapSupabaseError(
        FunctionException(status: 409, details: {'code': 'BXDUP'}),
      );

      expect(result, isA<DuplicateException>());
    });

    test('a details code BXERR maps to UnknownException', () {
      final result = mapSupabaseError(
        FunctionException(status: 500, details: {'code': 'BXERR'}),
      );

      expect(result, isA<UnknownException>());
    });

    test('details that are not a map map to UnknownException', () {
      final result = mapSupabaseError(
        FunctionException(status: 500, details: 'oops'),
      );

      expect(result, isA<UnknownException>());
    });
  });

  group('mapSupabaseError for auth and network failures', () {
    test('invalid_credentials maps to AuthFailedException', () {
      final result = mapSupabaseError(
        const AuthApiException(
          'Invalid login credentials',
          statusCode: '400',
          code: 'invalid_credentials',
        ),
      );

      expect(result, isA<AuthFailedException>());
    });

    for (final code in ['otp_expired', 'otp_disabled']) {
      test('$code maps to the wrong-code message', () {
        final result = mapSupabaseError(
          AuthApiException('x', statusCode: '403', code: code),
        );

        expect(result, isA<ValidationException>());
        expect(result.message, 'That code is wrong or has expired.');
      });
    }

    test('an invalid token message maps to the wrong-code message', () {
      final result = mapSupabaseError(
        const AuthException(
          'Token has expired or is invalid',
          statusCode: '400',
        ),
      );

      expect(result, isA<ValidationException>());
      expect(result.message, 'That code is wrong or has expired.');
    });

    for (final code in [
      'over_email_send_rate_limit',
      'over_request_rate_limit',
    ]) {
      test('$code maps to the rate-limit message', () {
        final result = mapSupabaseError(
          AuthApiException('x', statusCode: '429', code: code),
        );

        expect(result, isA<ValidationException>());
        expect(
          result.message,
          'Too many emails were sent. Try again in a few minutes.',
        );
      });
    }

    test('email_not_confirmed maps to the not-confirmed message', () {
      final result = mapSupabaseError(
        const AuthApiException(
          'Email not confirmed',
          statusCode: '400',
          code: 'email_not_confirmed',
        ),
      );

      expect(result, isA<ValidationException>());
      expect(
        result.message,
        'This account is not confirmed yet. Ask the club admin.',
      );
    });

    test('weak_password maps to the stronger-password message', () {
      final result = mapSupabaseError(
        const AuthApiException(
          'Password should be at least 8 characters.',
          statusCode: '422',
          code: 'weak_password',
        ),
      );

      expect(result, isA<ValidationException>());
      expect(
        result.message,
        'Choose a stronger password: at least 8 characters.',
      );
    });

    test('AuthWeakPasswordException maps to the stronger-password message', () {
      final result = mapSupabaseError(
        AuthWeakPasswordException(
          message: 'Password is known to be weak',
          statusCode: '422',
          reasons: const ['pwned'],
        ),
      );

      expect(result, isA<ValidationException>());
      expect(
        result.message,
        'Choose a stronger password: at least 8 characters.',
      );
    });

    test('same_password maps to the unused-password message', () {
      final result = mapSupabaseError(
        const AuthApiException(
          'New password should be different from the old password.',
          statusCode: '422',
          code: 'same_password',
        ),
      );

      expect(result, isA<ValidationException>());
      expect(result.message, 'Choose a password you have not used before.');
    });

    test('phone_provider_disabled maps to ValidationException', () {
      final result = mapSupabaseError(
        const AuthApiException(
          'Unsupported phone provider',
          statusCode: '400',
          code: 'phone_provider_disabled',
        ),
      );

      expect(result, isA<ValidationException>());
      expect(
        result.message,
        'Phone sign-in is not enabled on the server yet. Ask the club admin.',
      );
    });

    test('a "Phone logins are disabled" message maps to Validation', () {
      final result = mapSupabaseError(
        const AuthException('Phone logins are disabled', statusCode: '400'),
      );

      expect(result, isA<ValidationException>());
      expect(
        result.message,
        'Phone sign-in is not enabled on the server yet. Ask the club admin.',
      );
    });

    test('status 400 maps to AuthFailedException', () {
      final result = mapSupabaseError(
        const AuthException('bad request', statusCode: '400'),
      );

      expect(result, isA<AuthFailedException>());
    });

    test('AuthRetryableFetchException maps to OfflineException', () {
      final result = mapSupabaseError(
        AuthRetryableFetchException(message: 'x'),
      );

      expect(result, isA<OfflineException>());
    });

    test('another AuthException maps to UnknownException', () {
      final result = mapSupabaseError(
        const AuthException('server broke', statusCode: '500'),
      );

      expect(result, isA<UnknownException>());
    });

    test('SocketException maps to OfflineException', () {
      final result = mapSupabaseError(const SocketException('no route'));

      expect(result, isA<OfflineException>());
    });

    test('TimeoutException maps to OfflineException', () {
      final result = mapSupabaseError(TimeoutException('slow'));

      expect(result, isA<OfflineException>());
    });

    test('an http ClientException maps to OfflineException', () {
      final result = mapSupabaseError(_FakeClientException());

      expect(result, isA<OfflineException>());
    });

    test('an AppException passes through unchanged', () {
      const original = DuplicateException('again');

      expect(identical(mapSupabaseError(original), original), isTrue);
    });

    test('anything else maps to UnknownException', () {
      expect(mapSupabaseError(StateError('x')), isA<UnknownException>());
    });
  });

  group('mapSupabaseError for Edge Function transport types', () {
    test('a FunctionsHttpException with a BXDUP body maps to Duplicate', () {
      final result = mapSupabaseError(
        const FunctionsHttpException(
          status: 409,
          details: {'code': 'BXDUP', 'message': 'Number already exists'},
        ),
      );

      expect(result, isA<DuplicateException>());
      expect(result.message, 'Number already exists');
    });

    test('a FunctionsFetchException maps to OfflineException', () {
      expect(
        mapSupabaseError(const FunctionsFetchException(details: 'no network')),
        isA<OfflineException>(),
      );
    });
  });

  group('guardSupabase', () {
    test('returns the value on success', () async {
      expect(await guardSupabase(() async => 7), 7);
    });

    test('rethrows a failure as an AppException', () {
      expect(
        guardSupabase<int>(
          () async =>
              throw const PostgrestException(message: 'm', code: 'BXDUP'),
        ),
        throwsA(isA<DuplicateException>()),
      );
    });
  });
}
