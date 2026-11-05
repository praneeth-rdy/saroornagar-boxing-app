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
