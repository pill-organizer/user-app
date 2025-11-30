import 'package:equatable/equatable.dart';

class DeviceConfig extends Equatable {
  final String? pinHash;
  final Map<String, String> rfidTokens;
  final double tempMin;
  final double tempMax;
  final double humidityMin;
  final double humidityMax;
  final bool buzzerEnabled;
  final bool pushNotificationsEnabled;
  final int? lastSync;

  const DeviceConfig({
    this.pinHash,
    this.rfidTokens = const {},
    this.tempMin = 15.0,
    this.tempMax = 25.0,
    this.humidityMin = 30.0,
    this.humidityMax = 60.0,
    this.buzzerEnabled = true,
    this.pushNotificationsEnabled = true,
    this.lastSync,
  });

  factory DeviceConfig.fromJson(Map<dynamic, dynamic> json) {
    Map<String, String> tokens = {};
    if (json['rfidTokens'] != null) {
      final rfidData = json['rfidTokens'] as Map<dynamic, dynamic>;
      tokens = rfidData.map((key, value) => MapEntry(key.toString(), value.toString()));
    }

    return DeviceConfig(
      pinHash: json['pinHash'] as String?,
      rfidTokens: tokens,
      tempMin: (json['tempMin'] as num?)?.toDouble() ?? 15.0,
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 25.0,
      humidityMin: (json['humidityMin'] as num?)?.toDouble() ?? 30.0,
      humidityMax: (json['humidityMax'] as num?)?.toDouble() ?? 60.0,
      buzzerEnabled: json['buzzerEnabled'] as bool? ?? true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      lastSync: json['lastSync'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pinHash != null) 'pinHash': pinHash,
      if (rfidTokens.isNotEmpty) 'rfidTokens': rfidTokens,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'humidityMin': humidityMin,
      'humidityMax': humidityMax,
      'buzzerEnabled': buzzerEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      if (lastSync != null) 'lastSync': lastSync,
    };
  }

  DeviceConfig copyWith({
    String? pinHash,
    Map<String, String>? rfidTokens,
    double? tempMin,
    double? tempMax,
    double? humidityMin,
    double? humidityMax,
    bool? buzzerEnabled,
    bool? pushNotificationsEnabled,
    int? lastSync,
  }) {
    return DeviceConfig(
      pinHash: pinHash ?? this.pinHash,
      rfidTokens: rfidTokens ?? this.rfidTokens,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      humidityMin: humidityMin ?? this.humidityMin,
      humidityMax: humidityMax ?? this.humidityMax,
      buzzerEnabled: buzzerEnabled ?? this.buzzerEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  @override
  List<Object?> get props => [
        pinHash,
        rfidTokens,
        tempMin,
        tempMax,
        humidityMin,
        humidityMax,
        buzzerEnabled,
        pushNotificationsEnabled,
        lastSync,
      ];
}

