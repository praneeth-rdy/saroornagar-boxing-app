import 'routes.dart';

/// Where to send [location] for the current session, or null to stay.
String? redirectFor({required bool hasSession, required String location}) {
  if (!hasSession) return _isPublic(location) ? null : Routes.signIn;
  if (_isSignedOutOnly(location)) return Routes.today;
  return null;
}

// Sign-in and password recovery make no sense with a session.
bool _isSignedOutOnly(String location) =>
    location == Routes.signIn ||
    location == Routes.forgotPassword ||
    location == Routes.resetPassword;

// Compares whole segments so `/trials` (staff) is not mistaken for `/trial` (public).
bool _isPublic(String location) =>
    _isSignedOutOnly(location) ||
    location == Routes.trial ||
    location.startsWith('${Routes.trial}/');
