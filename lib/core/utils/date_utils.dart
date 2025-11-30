import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat displayDateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final DateFormat dayOfWeekFormat = DateFormat('EEEE');

  /// Parses a time string in HH:mm format to DateTime (using today's date)
  static DateTime parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Formats a DateTime to HH:mm string
  static String formatTime(DateTime dateTime) {
    return timeFormat.format(dateTime);
  }

  /// Formats a DateTime to display format
  static String formatDisplayDate(DateTime dateTime) {
    return displayDateFormat.format(dateTime);
  }

  /// Formats a DateTime to display format with time
  static String formatDisplayDateTime(DateTime dateTime) {
    return displayDateTimeFormat.format(dateTime);
  }

  /// Gets the day abbreviation (Mon, Tue, etc.)
  static String getDayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Converts a days string (e.g., "1,2,3,4,5") to list of weekdays
  static List<int> parseDays(String days) {
    if (days.isEmpty) return [];
    return days.split(',').map((e) => int.parse(e.trim())).toList();
  }

  /// Converts a list of weekdays to a days string
  static String formatDays(List<int> days) {
    return days.join(',');
  }

  /// Gets a human-readable string for the days
  static String getReadableDays(String days) {
    final daysList = parseDays(days);
    if (daysList.isEmpty) return 'Never';
    if (daysList.length == 7) return 'Every day';
    if (daysList.length == 5 && 
        daysList.contains(1) && 
        daysList.contains(2) && 
        daysList.contains(3) && 
        daysList.contains(4) && 
        daysList.contains(5)) {
      return 'Weekdays';
    }
    if (daysList.length == 2 && 
        daysList.contains(6) && 
        daysList.contains(7)) {
      return 'Weekends';
    }
    return daysList.map((d) => getDayAbbreviation(d)).join(', ');
  }

  /// Checks if the schedule should trigger today
  static bool isScheduledForToday(String days) {
    final daysList = parseDays(days);
    final today = DateTime.now().weekday;
    return daysList.contains(today);
  }

  /// Gets the timestamp for the start of today
  static int getTodayStartTimestamp() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return startOfDay.millisecondsSinceEpoch;
  }

  /// Gets the timestamp for 24 hours ago
  static int get24HoursAgoTimestamp() {
    return DateTime.now().subtract(const Duration(hours: 24)).millisecondsSinceEpoch;
  }

  /// Gets the timestamp for 7 days ago
  static int get7DaysAgoTimestamp() {
    return DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
  }

  /// Gets the timestamp for 30 days ago
  static int get30DaysAgoTimestamp() {
    return DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
  }
}

