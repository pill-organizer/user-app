import 'package:firebase_database/firebase_database.dart';
import '../model/environmental_data.dart';
import '../../../../core/constants/firebase_paths.dart';

class EnvironmentalRepository {
  const EnvironmentalRepository._({
    required DatabaseReference hourlyRef,
    required DatabaseReference dailyRef,
  }) : _hourlyRef = hourlyRef,
       _dailyRef = dailyRef;

  factory EnvironmentalRepository({FirebaseDatabase? database}) {
    final db = database ?? FirebaseDatabase.instance;
    return EnvironmentalRepository._(
      hourlyRef: db.ref(FirebasePaths.environmentalHourly),
      dailyRef: db.ref(FirebasePaths.environmentalDaily),
    );
  }
  final DatabaseReference _hourlyRef;
  final DatabaseReference _dailyRef;

  /// Stream of latest environmental data
  Stream<EnvironmentalData?> get latestDataStream {
    return _hourlyRef.orderByChild('timestamp').limitToLast(1).onValue.map((event) {
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
    final snapshot = await _hourlyRef.orderByChild('timestamp').limitToLast(1).get();
    if (snapshot.value == null) {
      return null;
    }
    final data = snapshot.value as Map<dynamic, dynamic>;
    final entry = data.entries.first;
    return EnvironmentalData.fromJson(entry.value as Map<dynamic, dynamic>);
  }

  /// Get hourly data for a time range
  Future<List<EnvironmentalData>> getHourlyData({
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) async {
    final snapshot = await _hourlyRef
        .orderByChild('timestamp')
        .startAt(startTimestamp.millisecondsSinceEpoch)
        .endAt(endTimestamp.millisecondsSinceEpoch)
        .get();

    if (snapshot.value == null) {
      return [];
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return EnvironmentalData.fromJson(entry.value as Map<dynamic, dynamic>);
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get hourly data for the last 24 hours
  Future<List<EnvironmentalData>> getLast24HoursData() async {
    final endDay = DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
    final startDay = endDay.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    return getHourlyData(startTimestamp: startDay, endTimestamp: endDay);
  }

  /// Get daily data for a date range
  Future<List<DailyEnvironmentalData>> getDailyData({
    required String startDate,
    required String endDate,
  }) async {
    final snapshot = await _dailyRef.orderByKey().startAt(startDate).endAt(endDate).get();

    if (snapshot.value == null) {
      return [];
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return DailyEnvironmentalData.fromJson(entry.value as Map<dynamic, dynamic>);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
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
