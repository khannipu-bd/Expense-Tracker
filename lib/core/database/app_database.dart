import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/categories_table.dart';
import 'tables/transactions_table.dart';
import 'tables/budgets_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CategoriesTable, TransactionsTable, BudgetsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'hisably_app_db');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultCategories();
      },
    );
  }

  Future<void> _seedDefaultCategories() async {
    final now = DateTime.now();
    const uuid = Uuid();

    final defaultExpenseCategories = [
      ('Food & Dining', 'restaurant', 0xFFF59E0B), // Amber
      ('Transportation', 'directions_car', 0xFF3B82F6), // Blue
      ('Shopping', 'shopping_bag', 0xFFEC4899), // Pink
      ('Bills & Utilities', 'receipt_long', 0xFF8B5CF6), // Purple
      ('Rent & Housing', 'home', 0xFF6366F1), // Indigo
      ('Health', 'medical_services', 0xFFEF4444), // Red
      ('Education', 'school', 0xFF06B6D4), // Cyan
      ('Entertainment', 'movie', 0xFF10B981), // Emerald
      ('Travel', 'flight', 0xFF14B8A6), // Teal
      ('Personal Care', 'face', 0xFFF97316), // Orange
      ('Family', 'people', 0xFF8B5CF6), // Purple
      ('Other', 'more_horiz', 0xFF64748B), // Slate
    ];

    final defaultIncomeCategories = [
      ('Salary', 'payments', 0xFF10B981), // Emerald
      ('Freelancing', 'work', 0xFF3B82F6), // Blue
      ('Business', 'store', 0xFF8B5CF6), // Purple
      ('Investments', 'trending_up', 0xFF06B6D4), // Cyan
      ('Gifts', 'card_giftcard', 0xFFEC4899), // Pink
      ('Other Income', 'account_balance_wallet', 0xFF64748B), // Slate
    ];

    for (final cat in defaultExpenseCategories) {
      await into(categoriesTable).insert(
        CategoriesTableCompanion.insert(
          id: 'cat_exp_${uuid.v4()}',
          name: cat.$1,
          iconName: cat.$2,
          colorValue: cat.$3,
          type: 'expense',
          isDefault: const Value(true),
          createdAt: now,
        ),
      );
    }

    for (final cat in defaultIncomeCategories) {
      await into(categoriesTable).insert(
        CategoriesTableCompanion.insert(
          id: 'cat_inc_${uuid.v4()}',
          name: cat.$1,
          iconName: cat.$2,
          colorValue: cat.$3,
          type: 'income',
          isDefault: const Value(true),
          createdAt: now,
        ),
      );
    }
  }
}
