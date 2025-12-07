import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat displayDateTimeFormat = DateFormat(
    'MMM dd, yyyy HH:mm',
  );
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
}
