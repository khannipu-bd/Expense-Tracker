import 'package:intl/intl.dart';
import 'date_utils.dart';

class DateFormatter {
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateGroupHeader(DateTime date) {
    if (AppDateUtils.isToday(date)) {
      return 'Today, ${DateFormat('MMM d').format(date)}';
    } else if (AppDateUtils.isYesterday(date)) {
      return 'Yesterday, ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    }
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatRange(DateTime start, DateTime end) {
    if (AppDateUtils.isSameDay(start, end)) {
      return formatShortDate(start);
    }
    return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }
}
