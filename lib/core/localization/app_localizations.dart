import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_name': 'Hisably',
      'home': 'Home',
      'history': 'History',
      'reports': 'Reports',
      'budgets': 'Budgets',
      'settings': 'Settings',
      'total_balance': 'Total Balance',
      'income': 'Income',
      'expenses': 'Expenses',
      'add_expense': 'Add Expense',
      'add_income': 'Add Income',
      'todays_limit': "Today's Limit",
      'spent_today': 'Spent Today',
      'over_limit': 'OVER LIMIT',
      'deficit_warning': 'Deficit: Expenses exceeded income',
      'recent_transactions': 'Recent Transactions',
      'see_all': 'See All',
      'add': 'Add',
      'financial_reports': 'Financial Reports',
      'budget_management': 'Budget Management',
      'settings_preferences': 'Settings & Preferences',
      'security_privacy': 'Security & Privacy',
      'app_lock': 'App Lock',
      'export_pdf': 'Export Statement (PDF)',
      'export_excel': 'Export Statement (Excel)',
      'clear_data': 'Clear All Application Data',
      'type_delete_to_confirm': 'Type DELETE to confirm reset',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'save': 'Save',
    },
    'bn': {
      'app_name': 'হিসাবলি',
      'home': 'হোম',
      'history': 'ইতিহাস',
      'reports': 'রিপোর্ট',
      'budgets': 'বাজেট',
      'settings': 'সেটিংস',
      'total_balance': 'মোট ব্যালেন্স',
      'income': 'আয়',
      'expenses': 'ব্যয়',
      'add_expense': 'ব্যয় যোগ করুন',
      'add_income': 'আয় যোগ করুন',
      'todays_limit': 'আজকের সীমা',
      'spent_today': 'আজ খরচ',
      'over_limit': 'সীমা অতিক্রম করেছে',
      'deficit_warning': 'ঘাটতি: খরচ আয়ের চেয়ে বেশি',
      'recent_transactions': 'সাম্প্রতিক লেনদেন',
      'see_all': 'সব দেখুন',
      'add': 'যোগ করুন',
      'financial_reports': 'আর্থিক রিপোর্ট',
      'budget_management': 'বাজেট ব্যবস্থাপনা',
      'settings_preferences': 'সেটিংস ও পছন্দসমূহ',
      'security_privacy': 'নিরাপত্তা ও গোপনীয়তা',
      'app_lock': 'অ্যাপ লক',
      'export_pdf': 'বিবরণী এক্সপোর্ট করুন (পিডিএফ)',
      'export_excel': 'বিবরণী এক্সপোর্ট করুন (এক্সেল)',
      'clear_data': 'সকল ডেটা মুছে ফেলুন',
      'type_delete_to_confirm': 'নিশ্চিত করতে DELETE লিখুন',
      'cancel': 'বাতিল',
      'delete': 'মুছে ফেলুন',
      'save': 'সংরক্ষণ',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
