enum TransactionType {
  expense,
  income;

  String get nameCapitalized {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }
}

enum BudgetPeriod {
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
    }
  }
}

enum FilterPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom;

  String get displayName {
    switch (this) {
      case FilterPeriod.today:
        return 'Today';
      case FilterPeriod.thisWeek:
        return 'This Week';
      case FilterPeriod.thisMonth:
        return 'This Month';
      case FilterPeriod.thisYear:
        return 'This Year';
      case FilterPeriod.custom:
        return 'Custom Range';
    }
  }
}

enum PaymentMethod {
  cash('Cash', 'cash_banknote'),
  bank('Bank Transfer', 'account_balance'),
  mobileWallet('Mobile Wallet', 'phone_android'),
  card('Card', 'credit_card');

  final String label;
  final String iconName;
  const PaymentMethod(this.label, this.iconName);
}

class AppConstants {
  static const String appName = 'Hisably';
  static const String appTagline = 'Expense Tracker';
  static const String defaultCurrencyCode = 'BDT';
  static const String defaultCurrencySymbol = '৳';

  static const double defaultOpeningBalance = 0.0;

  // Thresholds for budget alerts
  static const double budgetWarningThreshold = 0.80; // 80%
  static const double budgetExceededThreshold = 1.00; // 100%
}
