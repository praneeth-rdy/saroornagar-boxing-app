import 'package:saroornagar_boxing/features/trials/data/device_key_store.dart';

/// The key [MockDeviceKeyStore] hands out unless a test sets another.
const mockDeviceKey = 'MOCKDEVICEKEY2345678923456789ABC';

/// A fixed device key, with a count of reads for assertions.
class MockDeviceKeyStore implements DeviceKeyStore {
  MockDeviceKeyStore({this.deviceKey = mockDeviceKey});

  final String deviceKey;
  var reads = 0;

  @override
  Future<String> key() async {
    reads++;
    return deviceKey;
  }
}
