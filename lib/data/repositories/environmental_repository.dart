import 'package:firebase_database/firebase_database.dart';
import '../models/environmental_data.dart';
import '../../core/constants/firebase_paths.dart';

class EnvironmentalRepository {
  final FirebaseDatabase _database;
  late final DatabaseReference _hourlyRef;
  late final DatabaseReference _dailyRef;

  EnvironmentalRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance {
    _hourlyRef = _database.ref(FirebasePaths.environmentalHourly);
    _dailyRef = _database.ref(FirebasePaths.environmentalDaily);
  }

  /// Stream of latest environmental data
  Stream<EnvironmentalData?> get latestDataStream {
    return _hourlyRef
        .orderByChild('timestamp')
        .limitToLast(1)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return null;
      }
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final entry = data.entries.first;
      return EnvironmentalData.fromJson(entry.value as Map<dynamic, dynamic>);
    });
  }

  /// Get the latest environmental data
  Future<EnvironmentalData?> getLatestData() async {
    final snapshot = await _hourlyRef
        .orderByChild('timestamp')
        .limitToLast(1)
        .get();
    if (snapshot.value == null) {
      return null;
    }
    final data = snapshot.value as Map<dynamic, dynamic>;
    final entry = data.entries.first;
    return EnvironmentalData.fromJson(entry.value as Map<dynamic, dynamic>);
  }

  /// Get hourly data for a time range
  Future<List<EnvironmentalData>> getHourlyData({
    required int startTimestamp,
    required int endTimestamp,
  }) async {
    final snapshot = await _hourlyRef
        .orderByChild('timestamp')
        .startAt(startTimestamp)
        .endAt(endTimestamp)
        .get();
    
    if (snapshot.value == null) {
      return [];
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return EnvironmentalData.fromJson(entry.value as Map<dynamic, dynamic>);
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get hourly data for the last 24 hours
  Future<List<EnvironmentalData>> getLast24HoursData() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final yesterday = now - (24 * 60 * 60 * 1000);
    return getHourlyData(startTimestamp: yesterday, endTimestamp: now);
  }

  /// Get daily data for a date range
  Future<List<DailyEnvironmentalData>> getDailyData({
    required String startDate,
    required String endDate,
  }) async {
    final snapshot = await _dailyRef
        .orderByKey()
        .startAt(startDate)
        .endAt(endDate)
        .get();
    
    if (snapshot.value == null) {
      return [];
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return DailyEnvironmentalData.fromJson(entry.value as Map<dynamic, dynamic>);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get daily data for the last 7 days
  Future<List<DailyEnvironmentalData>> getLast7DaysData() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final startDate = _formatDate(weekAgo);
    final endDate = _formatDate(now);
    return getDailyData(startDate: startDate, endDate: endDate);
  }

  /// Get daily data for the last 30 days
  Future<List<DailyEnvironmentalData>> getLast30DaysData() async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final startDate = _formatDate(monthAgo);
    final endDate = _formatDate(now);
    return getDailyData(startDate: startDate, endDate: endDate);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

