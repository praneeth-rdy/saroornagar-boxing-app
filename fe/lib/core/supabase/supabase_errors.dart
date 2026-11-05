import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';

/// Maps any SDK, SQLSTATE or network failure to the matching [AppException].
AppException mapSupabaseError(Object error) {
  return switch (error) {
    AppException() => error,
    PostgrestException() => _fromPostgrest(error),
    // No response reached the app, so the body has no code to read.
    FunctionsFetchException() => const OfflineException(),
    FunctionException() => _fromFunction(error),
    AuthRetryableFetchException() => const OfflineException(),
    AuthException() => _fromAuth(error),
    IOException() || TimeoutException() => const OfflineException(),
    _ when _isHttpClientException(error) => const OfflineException(),
    _ => const UnknownException(),
  };
}

/// Runs a Supabase call and rethrows any failure as an [AppException].
Future<T> guardSupabase<T>(Future<T> Function() run) async {
  try {
    return await run();
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(mapSupabaseError(error), stackTrace);
  }
}

AppException _fromPostgrest(PostgrestException error) {
  final mapped = _fromServerCode(error.code, error.message);
  if (mapped != null) return mapped;
  if (error.code == '42501' || error.code == 'PGRST301') {
    return const PermissionException();
  }
  return const UnknownException();
}

AppException _fromFunction(FunctionException error) {
  final details = error.details;
  if (details is Map) {
    final code = details['code'];
    final message = details['message'];
    final mapped = _fromServerCode(
      code is String ? code : null,
      message is String ? message : null,
    );
    if (mapped != null) return mapped;
  }
  return const UnknownException();
}

AppException _fromAuth(AuthException error) {
  if (error.code == 'invalid_credentials' || error.statusCode == '400') {
    return const AuthFailedException();
  }
  return const UnknownException();
}

/// The BX codes raised by `private.fail` and returned by Edge Functions.
AppException? _fromServerCode(String? code, String? message) {
  final text = (message == null || message.trim().isEmpty) ? null : message;
  return switch (code) {
    'BXVAL' => ValidationException(text ?? ValidationException.defaultMessage),
    'BXPRM' => PermissionException(text ?? PermissionException.defaultMessage),
    'BXNTF' => NotFoundException(text ?? NotFoundException.defaultMessage),
    'BXDUP' => DuplicateException(text ?? DuplicateException.defaultMessage),
    'BXERR' => UnknownException(text ?? UnknownException.defaultMessage),
    _ => null,
  };
}

// package:http is only a transitive dependency, so its ClientException is matched by
// its string form instead of a type import.
bool _isHttpClientException(Object error) =>
    error.toString().startsWith('ClientException');
