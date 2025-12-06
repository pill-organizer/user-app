import 'package:equatable/equatable.dart';

class EnvironmentalData extends Equatable {
  final double temperature;
  final double humidity;
  final int timestamp;

  const EnvironmentalData({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory EnvironmentalData.fromJson(Map<dynamic, dynamic> json) {
    return EnvironmentalData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'temperature': temperature, 'humidity': humidity, 'timestamp': timestamp};
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  @override
  List<Object> get props => [temperature, humidity, timestamp];
}

class DailyEnvironmentalData extends Equatable {
  final String date;
  final double tempMin;
  final double tempMax;
  final double tempAvg;
  final double humidityMin;
  final double humidityMax;
  final double humidityAvg;

  const DailyEnvironmentalData({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.tempAvg,
    required this.humidityMin,
    required this.humidityMax,
    required this.humidityAvg,
  });

  factory DailyEnvironmentalData.fromJson(Map<dynamic, dynamic> json) {
    return DailyEnvironmentalData(
      date: json['date'] as String,
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      tempAvg: (json['tempAvg'] as num).toDouble(),
      humidityMin: (json['humidityMin'] as num).toDouble(),
      humidityMax: (json['humidityMax'] as num).toDouble(),
      humidityAvg: (json['humidityAvg'] as num).toDouble(),
    );
  }

  @override
  List<Object> get props => [
    date,
    tempMin,
    tempMax,
    tempAvg,
    humidityMin,
    humidityMax,
    humidityAvg,
  ];
}
