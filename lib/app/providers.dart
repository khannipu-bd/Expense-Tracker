import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/app_database.dart';
import '../features/categories/data/repositories/category_repository_impl.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/budgets/data/repositories/budget_repository_impl.dart';
import '../features/budgets/domain/repositories/budget_repository.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/reports/data/repositories/report_repository_impl.dart';
import '../features/reports/domain/repositories/report_repository.dart';
import '../features/settings/domain/entities/app_settings.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences in main() override');
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(db);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final db = ref.watch(databaseProvider);
  return SettingsRepositoryImpl(prefs, db);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return DashboardRepositoryImpl(db, txRepo, budgetRepo, settingsRepo);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final txRepo = ref.watch(transactionRepositoryProvider);
  return ReportRepositoryImpl(txRepo);
});

// App Settings State Notifier / Provider
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
      final repo = ref.watch(settingsRepositoryProvider);
      return SettingsNotifier(repo);
    });

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repo.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    await _repo.updateSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }
}
