class AppDateUtils {
  /// Start of the day (00:00:00.000)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// End of the day (23:59:59.999)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Start of the week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final start = date.subtract(Duration(days: date.weekday - 1));
    return startOfDay(start);
  }

  /// End of the week (Sunday 23:59:59.999)
  static DateTime endOfWeek(DateTime date) {
    final end = date.add(Duration(days: DateTime.sunday - date.weekday));
    return endOfDay(end);
  }

  /// Start of the month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// End of the month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1));
    return endOfDay(lastDay);
  }

  /// Start of the year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// End of the year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Check if two DateTimes fall on the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if date is Today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is Yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}
