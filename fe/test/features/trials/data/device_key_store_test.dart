import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/features/trials/data/device_key_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('creates a 32-character key without look-alike characters', () async {
    final key = await SharedPreferencesDeviceKeyStore().key();

    expect(key, matches(RegExp(r'^[A-HJ-NP-Z2-9]{32}$')));
  });

  test('reuses the stored key across calls and store instances', () async {
    final first = await SharedPreferencesDeviceKeyStore().key();
    final store = SharedPreferencesDeviceKeyStore();

    expect(await store.key(), first);
    expect(await store.key(), first);
    expect(await SharedPreferencesDeviceKeyStore().key(), first);
  });

  test('keeps a key that was already stored', () async {
    SharedPreferences.setMockInitialValues({
      'trial_device_key': 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789',
    });

    expect(
      await SharedPreferencesDeviceKeyStore().key(),
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789',
    );
  });
}
