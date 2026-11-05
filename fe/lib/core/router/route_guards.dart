import 'routes.dart';

/// Where to send [location] for the current session, or null to stay.
String? redirectFor({required bool hasSession, required String location}) {
  if (!hasSession) return _isPublic(location) ? null : Routes.signIn;
  if (location == Routes.signIn) return Routes.today;
  return null;
}

// Compares whole segments so `/trials` (staff) is not mistaken for `/trial` (public).
bool _isPublic(String location) =>
    location == Routes.signIn ||
    location == Routes.trial ||
    location.startsWith('${Routes.trial}/');
