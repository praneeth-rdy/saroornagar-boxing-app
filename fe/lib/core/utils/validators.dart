import 'dart:convert';

import 'phone_format.dart';

const _passwordMinLength = 8;

// Auth hashes with bcrypt, which reads at most 72 bytes, so the upper bound is in bytes.
const _passwordMaxBytes = 72;

/// Fails on null or blank input, e.g. `Enter your name` for label `your name`.
String? requiredText(String? value, {String label = 'a value'}) {
  if (value == null || value.trim().isEmpty) return 'Enter $label';
  return null;
}

String? phoneText(String? value) {
  if (value == null || normalizePhone(value) == null) {
    return 'Enter a 10-digit mobile number';
  }
  return null;
}

/// Mirrors the admin-staff function: 8 characters minimum, 72 UTF-8 bytes maximum.
String? passwordText(String? value) {
  if (value == null ||
      value.runes.length < _passwordMinLength ||
      utf8.encode(value).length > _passwordMaxBytes) {
    return 'Enter a password of 8 to 72 characters';
  }
  return null;
}
