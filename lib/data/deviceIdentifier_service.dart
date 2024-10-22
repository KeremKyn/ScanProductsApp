import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceIdentifierService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static String? _deviceIdentifier;

  static Future<void> initialize() async {
    String? deviceId = await _storage.read(key: 'deviceIdentifier');
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await _storage.write(key: 'deviceIdentifier', value: deviceId);
    }
    _deviceIdentifier = deviceId;
  }

  static String? get deviceIdentifier => _deviceIdentifier;
}
