/// Every failure a repository surfaces; screens render these and nothing else.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// User-facing text: the server's message when it sent one, else a default.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ValidationException extends AppException {
  const ValidationException([super.message = defaultMessage]);

  static const defaultMessage = 'Check the details and try again.';
}

class PermissionException extends AppException {
  const PermissionException([super.message = defaultMessage]);

  static const defaultMessage = 'You do not have access to this.';
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = defaultMessage]);

  static const defaultMessage = 'This was not found. It may have been removed.';
}

class DuplicateException extends AppException {
  const DuplicateException([super.message = defaultMessage]);

  static const defaultMessage = 'This has already been recorded.';
}

class OfflineException extends AppException {
  const OfflineException([super.message = defaultMessage]);

  static const defaultMessage =
      'No connection. Check your internet and try again.';
}

/// Wrong phone number or password at sign-in.
class AuthFailedException extends AppException {
  const AuthFailedException([super.message = defaultMessage]);

  static const defaultMessage = 'Wrong phone number or password.';
}

class UnknownException extends AppException {
  const UnknownException([super.message = defaultMessage]);

  static const defaultMessage = 'Something went wrong. Try again.';
}
