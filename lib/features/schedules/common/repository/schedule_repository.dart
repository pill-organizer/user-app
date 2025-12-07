import 'package:firebase_database/firebase_database.dart';
import '../model/schedule.dart';
import '../../../../core/constants/firebase_paths.dart';

class ScheduleRepository {
  final FirebaseDatabase _database;
  late final DatabaseReference _schedulesRef;

  ScheduleRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance {
    _schedulesRef = _database.ref(FirebasePaths.schedules);
  }

  /// Stream of all schedules
  Stream<List<Schedule>> get schedulesStream {
    return _schedulesRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return <Schedule>[];
      }
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        return Schedule.fromJson(
          entry.key.toString(),
          entry.value as Map<dynamic, dynamic>,
        );
      }).toList()..sort((a, b) => a.time.compareTo(b.time));
    });
  }

  /// Get all schedules
  Future<List<Schedule>> getSchedules() async {
    final snapshot = await _schedulesRef.get();
    if (snapshot.value == null) {
      return [];
    }
    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return Schedule.fromJson(
        entry.key.toString(),
        entry.value as Map<dynamic, dynamic>,
      );
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
  }

  /// Get a single schedule by ID
  Future<Schedule?> getSchedule(String id) async {
    final snapshot = await _schedulesRef.child(id).get();
    if (snapshot.value == null) {
      return null;
    }
    return Schedule.fromJson(id, snapshot.value as Map<dynamic, dynamic>);
  }

  /// Create a new schedule
  Future<String> createSchedule(Schedule schedule) async {
    final ref = _schedulesRef.push();
    await ref.set(schedule.toJson());
    await _requestSync();
    return ref.key!;
  }

  /// Update an existing schedule
  Future<void> updateSchedule(Schedule schedule) async {
    if (schedule.id == null) {
      throw Exception('Schedule ID is required for update');
    }
    await _schedulesRef.child(schedule.id!).update(schedule.toJson());
    await _requestSync();
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String id) async {
    await _schedulesRef.child(id).remove();
    await _requestSync();
  }

  /// Toggle schedule enabled state
  Future<void> toggleSchedule(String id, bool enabled) async {
    await _schedulesRef.child(id).update({'enabled': enabled});
    await _requestSync();
  }

  /// Request sync with the device
  Future<void> _requestSync() async {
    await _database.ref(FirebasePaths.deviceSyncRequest).set(true);
  }
}
