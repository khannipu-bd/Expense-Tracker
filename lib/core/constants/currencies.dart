class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class AppCurrencies {
  static const CurrencyInfo defaultCurrency = CurrencyInfo(
    code: 'BDT',
    symbol: '৳',
    name: 'Bangladeshi Taka',
  );

  static const List<CurrencyInfo> allCurrencies = [
    CurrencyInfo(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka'),
    CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyInfo(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar'),
    CurrencyInfo(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    CurrencyInfo(code: 'SAR', symbol: 'SR', name: 'Saudi Riyal'),
    CurrencyInfo(code: 'AED', symbol: 'AED', name: 'UAE Dirham'),
  ];

  static CurrencyInfo findByCode(String code) {
    return allCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => defaultCurrency,
    );
  }
}
