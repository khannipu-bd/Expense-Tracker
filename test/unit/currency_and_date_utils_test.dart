import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('centsToDouble converts integer minor units to double', () {
      expect(CurrencyFormatter.centsToDouble(10000), 100.0);
      expect(CurrencyFormatter.centsToDouble(2550), 25.50);
      expect(CurrencyFormatter.centsToDouble(0), 0.0);
    });

    test('doubleToCents converts double amount to integer minor units', () {
      expect(CurrencyFormatter.doubleToCents(100.0), 10000);
      expect(CurrencyFormatter.doubleToCents(25.50), 2550);
      expect(CurrencyFormatter.doubleToCents(0.0), 0);
    });

    test('formatCents formats string with currency symbol and locale', () {
      final formatted = CurrencyFormatter.formatCents(
        2550,
        currencySymbol: '৳',
      );
      expect(formatted, '৳ 25.50');
    });

    test('formatCents displays sign correctly for expenses and income', () {
      final exp = CurrencyFormatter.formatCents(
        1500,
        currencySymbol: '\$',
        showSign: true,
        isExpense: true,
      );
      expect(exp, '- \$ 15.00');

      final inc = CurrencyFormatter.formatCents(
        5000,
        currencySymbol: '\$',
        showSign: true,
        isExpense: false,
      );
      expect(inc, '+ \$ 50.00');
    });
  });

  group('AppDateUtils Tests', () {
    final baseDate = DateTime(2025, 10, 24, 15, 30, 45); // Friday

    test('startOfDay returns 00:00:00.000', () {
      final start = AppDateUtils.startOfDay(baseDate);
      expect(start, DateTime(2025, 10, 24, 0, 0, 0, 0));
    });

    test('endOfDay returns 23:59:59.999', () {
      final end = AppDateUtils.endOfDay(baseDate);
      expect(end, DateTime(2025, 10, 24, 23, 59, 59, 999));
    });

    test('startOfWeek returns Monday of that week', () {
      final startWeek = AppDateUtils.startOfWeek(
        baseDate,
      ); // Friday Oct 24 -> Mon Oct 20
      expect(startWeek.weekday, DateTime.monday);
      expect(startWeek, DateTime(2025, 10, 20, 0, 0, 0));
    });

    test('endOfWeek returns Sunday 23:59:59.999 of that week', () {
      final endWeek = AppDateUtils.endOfWeek(
        baseDate,
      ); // Fri Oct 24 -> Sun Oct 26
      expect(endWeek.weekday, DateTime.sunday);
      expect(endWeek, DateTime(2025, 10, 26, 23, 59, 59, 999));
    });

    test('startOfMonth and endOfMonth return first and last day of month', () {
      final startMonth = AppDateUtils.startOfMonth(baseDate);
      final endMonth = AppDateUtils.endOfMonth(baseDate);

      expect(startMonth, DateTime(2025, 10, 1, 0, 0, 0));
      expect(endMonth, DateTime(2025, 10, 31, 23, 59, 59, 999));
    });

    test('startOfYear and endOfYear return Jan 1 and Dec 31', () {
      final startYear = AppDateUtils.startOfYear(baseDate);
      final endYear = AppDateUtils.endOfYear(baseDate);

      expect(startYear, DateTime(2025, 1, 1, 0, 0, 0));
      expect(endYear, DateTime(2025, 12, 31, 23, 59, 59, 999));
    });
  });
}
