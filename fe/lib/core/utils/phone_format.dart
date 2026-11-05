final _nonDigits = RegExp(r'[^0-9]');

/// Formats a stored `91XXXXXXXXXX` number as `+91 98765 43210`; anything else is returned as is.
String formatPhone(String digits) {
  if (digits.length != 12 ||
      !digits.startsWith('91') ||
      digits.contains(_nonDigits)) {
    return digits;
  }
  return '+91 ${digits.substring(2, 7)} ${digits.substring(7)}';
}

/// Same rule as `private.normalize_phone`: digits only, 10 digits get the 91 prefix.
String? normalizePhone(String input) {
  final digits = input.replaceAll(_nonDigits, '');
  if (digits.length == 10) return '91$digits';
  if (digits.length == 12 && digits.startsWith('91')) return digits;
  return null;
}
