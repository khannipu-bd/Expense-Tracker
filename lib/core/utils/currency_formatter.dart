import 'package:intl/intl.dart';

class CurrencyFormatter {
  static double centsToDouble(int cents) => cents / 100.0;
  static int doubleToCents(double amount) => (amount * 100.0).round();

  static String formatCents(
    int cents, {
    required String currencySymbol,
    bool showSign = false,
    bool isExpense = false,
  }) {
    final amount = centsToDouble(cents.abs());
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedStr = formatter.format(amount);

    String prefix = '';
    if (showSign) {
      if (isExpense) {
        prefix = '- ';
      } else {
        prefix = '+ ';
      }
    }

    return '$prefix$currencySymbol $formattedStr';
  }

  static String formatDouble(
    double amount, {
    required String currencySymbol,
    bool showSign = false,
    bool isExpense = false,
  }) {
    return formatCents(
      doubleToCents(amount),
      currencySymbol: currencySymbol,
      showSign: showSign,
      isExpense: isExpense,
    );
  }
}
