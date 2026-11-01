import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;
  final AppDatabase _db;

  static const String _keyCurrency = 'setting_currency';
  static const String _keyThemeMode = 'setting_theme_mode';
  static const String _keyOpeningBalance = 'setting_opening_balance';
  static const String _keyDefaultTxType = 'setting_default_tx_type';
  static const String _keyDefaultPeriod = 'setting_default_period';
  static const String _keyAppLockEnabled = 'setting_app_lock_enabled';
  static const String _keyAppLockPin = 'setting_app_lock_pin';
  static const String _keyLanguageCode = 'setting_language_code';

  SettingsRepositoryImpl(this._prefs, this._db);

  @override
  Stream<AppSettings> watchSettings() async* {
    yield await getSettings();
  }

  @override
  Future<AppSettings> getSettings() async {
    final currencyCode =
        _prefs.getString(_keyCurrency) ?? AppConstants.defaultCurrencyCode;
    final themeIndex = _prefs.getInt(_keyThemeMode) ?? ThemeMode.system.index;
    final openingBalance = _prefs.getInt(_keyOpeningBalance) ?? 0;
    final txTypeIndex =
        _prefs.getInt(_keyDefaultTxType) ?? TransactionType.expense.index;
    final periodIndex =
        _prefs.getInt(_keyDefaultPeriod) ?? FilterPeriod.thisMonth.index;
    final isAppLockEnabled = _prefs.getBool(_keyAppLockEnabled) ?? false;
    final appLockPin = _prefs.getString(_keyAppLockPin) ?? '';
    final languageCode = _prefs.getString(_keyLanguageCode) ?? 'en';

    return AppSettings(
      currencyCode: currencyCode,
      themeMode: ThemeMode.values[themeIndex],
      openingBalanceCents: openingBalance,
      defaultTransactionType: TransactionType.values[txTypeIndex],
      defaultDashboardPeriod: FilterPeriod.values[periodIndex],
      isAppLockEnabled: isAppLockEnabled,
      appLockPin: appLockPin,
      languageCode: languageCode,
    );
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    await _prefs.setString(_keyCurrency, settings.currencyCode);
    await _prefs.setInt(_keyThemeMode, settings.themeMode.index);
    await _prefs.setInt(_keyOpeningBalance, settings.openingBalanceCents);
    await _prefs.setInt(
      _keyDefaultTxType,
      settings.defaultTransactionType.index,
    );
    await _prefs.setInt(
      _keyDefaultPeriod,
      settings.defaultDashboardPeriod.index,
    );
    await _prefs.setBool(_keyAppLockEnabled, settings.isAppLockEnabled);
    await _prefs.setString(_keyAppLockPin, settings.appLockPin);
    await _prefs.setString(_keyLanguageCode, settings.languageCode);
  }

  @override
  Future<String> exportDataAsJson() async {
    final settings = await getSettings();
    final categoriesData = await _db.select(_db.categoriesTable).get();
    final transactionsData = await _db.select(_db.transactionsTable).get();
    final budgetsData = await _db.select(_db.budgetsTable).get();

    final exportMap = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': {
        'currencyCode': settings.currencyCode,
        'openingBalanceCents': settings.openingBalanceCents,
      },
      'categories': categoriesData
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'iconName': c.iconName,
              'colorValue': c.colorValue,
              'type': c.type,
              'isDefault': c.isDefault,
              'isArchived': c.isArchived,
              'createdAt': c.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'transactions': transactionsData
          .map(
            (t) => {
              'id': t.id,
              'type': t.type,
              'amountCents': t.amountCents,
              'categoryId': t.categoryId,
              'date': t.date.toIso8601String(),
              'paymentMethod': t.paymentMethod,
              'note': t.note,
              'createdAt': t.createdAt.toIso8601String(),
              'updatedAt': t.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'budgets': budgetsData
          .map(
            (b) => {
              'id': b.id,
              'categoryId': b.categoryId,
              'amountCents': b.amountCents,
              'period': b.period,
              'createdAt': b.createdAt.toIso8601String(),
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  @override
  Future<void> importDataFromJson(
    String jsonStr, {
    required bool mergeWithExisting,
  }) async {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (!map.containsKey('version') || !map.containsKey('categories')) {
        throw const ImportFailure('Invalid backup file format.');
      }

      final categoriesList = (map['categories'] as List)
          .cast<Map<String, dynamic>>();
      final transactionsList = (map['transactions'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final budgetsList = (map['budgets'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      if (!mergeWithExisting) {
        await clearAllAppData();
      }

      if (map.containsKey('settings')) {
        final settingsMap = map['settings'] as Map<String, dynamic>;
        final currentSettings = await getSettings();
        await updateSettings(
          currentSettings.copyWith(
            currencyCode: settingsMap['currencyCode'] as String?,
            openingBalanceCents: settingsMap['openingBalanceCents'] as int?,
          ),
        );
      }

      for (final catMap in categoriesList) {
        final id = catMap['id'] as String;
        final existing = await (_db.select(
          _db.categoriesTable,
        )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

        if (existing == null) {
          await _db
              .into(_db.categoriesTable)
              .insertOnConflictUpdate(
                CategoriesTableCompanion.insert(
                  id: id,
                  name: catMap['name'] as String,
                  iconName: catMap['iconName'] as String,
                  colorValue: catMap['colorValue'] as int,
                  type: catMap['type'] as String,
                  isDefault: Value(catMap['isDefault'] as bool? ?? false),
                  isArchived: Value(catMap['isArchived'] as bool? ?? false),
                  createdAt: DateTime.parse(catMap['createdAt'] as String),
                ),
              );
        }
      }

      for (final txMap in transactionsList) {
        final id = txMap['id'] as String;
        await _db
            .into(_db.transactionsTable)
            .insertOnConflictUpdate(
              TransactionsTableCompanion.insert(
                id: id,
                type: txMap['type'] as String,
                amountCents: txMap['amountCents'] as int,
                categoryId: txMap['categoryId'] as String,
                date: DateTime.parse(txMap['date'] as String),
                paymentMethod: txMap['paymentMethod'] as String,
                note: Value(txMap['note'] as String?),
                createdAt: DateTime.parse(txMap['createdAt'] as String),
                updatedAt: DateTime.parse(txMap['updatedAt'] as String),
              ),
            );
      }

      for (final bMap in budgetsList) {
        final id = bMap['id'] as String;
        await _db
            .into(_db.budgetsTable)
            .insertOnConflictUpdate(
              BudgetsTableCompanion.insert(
                id: id,
                categoryId: Value(bMap['categoryId'] as String?),
                amountCents: bMap['amountCents'] as int,
                period: bMap['period'] as String,
                createdAt: DateTime.parse(bMap['createdAt'] as String),
              ),
            );
      }
    } catch (e) {
      if (e is ImportFailure) rethrow;
      throw ImportFailure('Failed to import backup data: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllAppData() async {
    await _db.delete(_db.transactionsTable).go();
    await _db.delete(_db.budgetsTable).go();
    await _db.delete(_db.categoriesTable).go();
    await _prefs.clear();
  }
}
