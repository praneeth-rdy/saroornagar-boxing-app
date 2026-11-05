import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';

/// The random key that ties a visitor's trial bookings to this install.
abstract class DeviceKeyStore {
  /// The stored key, created and saved on first use.
  Future<String> key();
}

const _preferenceName = 'trial_device_key';
const _keyLength = 32;

// Upper-case letters and digits without the look-alikes 0, 1, I and O.
const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

class SharedPreferencesDeviceKeyStore implements DeviceKeyStore {
  SharedPreferencesDeviceKeyStore({Random? random})
    : random = random ?? Random.secure();

  final Random random;

  // Shared so that two callers on first use do not each create a key.
  Future<String>? _pending;

  @override
  Future<String> key() => _pending ??= _loadOrCreate();

  Future<String> _loadOrCreate() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString(_preferenceName);
      if (stored != null && stored.length == _keyLength) return stored;
      final created = String.fromCharCodes(
        List.generate(
          _keyLength,
          (_) => _alphabet.codeUnitAt(random.nextInt(_alphabet.length)),
        ),
      );
      await preferences.setString(_preferenceName, created);
      return created;
    } catch (_) {
      // A later call tries storage again instead of reusing the failure.
      _pending = null;
      throw const UnknownException();
    }
  }
}
