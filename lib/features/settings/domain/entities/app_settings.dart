import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/currencies.dart';

class AppSettings {
  final String currencyCode;
  final ThemeMode themeMode;
  final int openingBalanceCents;
  final TransactionType defaultTransactionType;
  final FilterPeriod defaultDashboardPeriod;
  final bool isAppLockEnabled;
  final String appLockPin;
  final String languageCode; // 'en' or 'bn'

  const AppSettings({
    this.currencyCode = AppConstants.defaultCurrencyCode,
    this.themeMode = ThemeMode.system,
    this.openingBalanceCents = 0,
    this.defaultTransactionType = TransactionType.expense,
    this.defaultDashboardPeriod = FilterPeriod.thisMonth,
    this.isAppLockEnabled = false,
    this.appLockPin = '',
    this.languageCode = 'en',
  });

  CurrencyInfo get currency => AppCurrencies.findByCode(currencyCode);

  AppSettings copyWith({
    String? currencyCode,
    ThemeMode? themeMode,
    int? openingBalanceCents,
    TransactionType? defaultTransactionType,
    FilterPeriod? defaultDashboardPeriod,
    bool? isAppLockEnabled,
    String? appLockPin,
    String? languageCode,
  }) {
    return AppSettings(
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
      openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
      defaultTransactionType:
          defaultTransactionType ?? this.defaultTransactionType,
      defaultDashboardPeriod:
          defaultDashboardPeriod ?? this.defaultDashboardPeriod,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      appLockPin: appLockPin ?? this.appLockPin,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
