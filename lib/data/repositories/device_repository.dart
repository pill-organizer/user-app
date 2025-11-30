import 'package:firebase_database/firebase_database.dart';
import '../models/device_config.dart';
import '../../core/constants/firebase_paths.dart';
import '../../core/utils/hash_utils.dart';

class DeviceRepository {
  final FirebaseDatabase _database;
  late final DatabaseReference _configRef;
  late final DatabaseReference _syncRef;

  DeviceRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance {
    _configRef = _database.ref(FirebasePaths.deviceConfig);
    _syncRef = _database.ref(FirebasePaths.deviceSyncRequest);
  }

  /// Stream of device configuration changes
  Stream<DeviceConfig> get configStream {
    return _configRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return const DeviceConfig();
      }
      return DeviceConfig.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
    });
  }

  /// Get current device configuration
  Future<DeviceConfig> getConfig() async {
    final snapshot = await _configRef.get();
    if (snapshot.value == null) {
      return const DeviceConfig();
    }
    return DeviceConfig.fromJson(snapshot.value as Map<dynamic, dynamic>);
  }

  /// Update the PIN (stored as SHA-256 hash)
  Future<void> updatePin(String newPin) async {
    final hash = HashUtils.hashSha256(newPin);
    await _configRef.child(FirebasePaths.pinHash).set(hash);
    await _requestSync();
  }

  /// Add an RFID token (stored as SHA-256 hash)
  Future<void> addRfidToken(String tokenName, String token) async {
    final hash = HashUtils.hashSha256(token);
    await _configRef.child('${FirebasePaths.rfidTokens}/$tokenName').set(hash);
    await _requestSync();
  }

  /// Remove an RFID token
  Future<void> removeRfidToken(String tokenName) async {
    await _configRef.child('${FirebasePaths.rfidTokens}/$tokenName').remove();
    await _requestSync();
  }

  /// Update temperature thresholds
  Future<void> updateTemperatureThresholds({required double min, required double max}) async {
    await _configRef.update({FirebasePaths.tempMin: min, FirebasePaths.tempMax: max});
    await _requestSync();
  }

  /// Update humidity thresholds
  Future<void> updateHumidityThresholds({required double min, required double max}) async {
    await _configRef.update({FirebasePaths.humidityMin: min, FirebasePaths.humidityMax: max});
    await _requestSync();
  }

  /// Toggle buzzer
  Future<void> setBuzzerEnabled(bool enabled) async {
    await _configRef.child(FirebasePaths.buzzerEnabled).set(enabled);
    await _requestSync();
  }

  /// Toggle push notifications
  Future<void> setPushNotificationsEnabled(bool enabled) async {
    await _configRef.child(FirebasePaths.pushNotificationsEnabled).set(enabled);
  }

  /// Request sync with the device
  Future<void> _requestSync() async {
    await _syncRef.set(true);
  }

  /// Update full config
  Future<void> updateConfig(DeviceConfig config) async {
    await _configRef.update(config.toJson());
    await _requestSync();
  }
}
