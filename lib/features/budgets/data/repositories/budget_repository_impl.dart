import 'package:drift/drift.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _db;

  BudgetRepositoryImpl(this._db);

  Future<BudgetEntity> _mapRowToEntity(TypedResult row) async {
    final bData = row.readTable(_db.budgetsTable);
    final catData = row.readTableOrNull(_db.categoriesTable);

    CategoryEntity? category;
    if (catData != null) {
      category = CategoryEntity(
        id: catData.id,
        name: catData.name,
        iconName: catData.iconName,
        colorValue: catData.colorValue,
        type: catData.type == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        isDefault: catData.isDefault,
        isArchived: catData.isArchived,
        createdAt: catData.createdAt,
      );
    }

    final period = bData.period == 'weekly'
        ? BudgetPeriod.weekly
        : BudgetPeriod.monthly;

    final now = DateTime.now();
    final DateTime startDate = period == BudgetPeriod.weekly
        ? AppDateUtils.startOfWeek(now)
        : AppDateUtils.startOfMonth(now);
    final DateTime endDate = period == BudgetPeriod.weekly
        ? AppDateUtils.endOfWeek(now)
        : AppDateUtils.endOfMonth(now);

    final query = _db.select(_db.transactionsTable)
      ..where(
        (tbl) =>
            tbl.type.equals('expense') &
            tbl.date.isBiggerOrEqualValue(startDate) &
            tbl.date.isSmallerOrEqualValue(endDate),
      );

    if (bData.categoryId != null) {
      query.where((tbl) => tbl.categoryId.equals(bData.categoryId!));
    }

    final txs = await query.get();
    final spentCents = txs.fold<int>(0, (sum, tx) => sum + tx.amountCents);

    return BudgetEntity(
      id: bData.id,
      categoryId: bData.categoryId,
      category: category,
      amountCents: bData.amountCents,
      period: period,
      createdAt: bData.createdAt,
      spentCents: spentCents,
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildBaseQuery() {
    return _db.select(_db.budgetsTable).join([
      leftOuterJoin(
        _db.categoriesTable,
        _db.categoriesTable.id.equalsExp(_db.budgetsTable.categoryId),
      ),
    ]);
  }

  @override
  Stream<List<BudgetEntity>> watchAllBudgets() {
    return _buildBaseQuery().watch().asyncMap((rows) async {
      final list = <BudgetEntity>[];
      for (final row in rows) {
        list.add(await _mapRowToEntity(row));
      }
      return list;
    });
  }

  @override
  Future<List<BudgetEntity>> getAllBudgets() async {
    final rows = await _buildBaseQuery().get();
    final list = <BudgetEntity>[];
    for (final row in rows) {
      list.add(await _mapRowToEntity(row));
    }
    return list;
  }

  @override
  Future<BudgetEntity?> getBudgetById(String id) async {
    final query = _buildBaseQuery()..where(_db.budgetsTable.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRowToEntity(row);
  }

  @override
  Future<void> addBudget(BudgetEntity budget) async {
    await _db
        .into(_db.budgetsTable)
        .insert(
          BudgetsTableCompanion.insert(
            id: budget.id,
            categoryId: Value(budget.categoryId),
            amountCents: budget.amountCents,
            period: budget.period.name,
            createdAt: budget.createdAt,
          ),
        );
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) async {
    await (_db.update(
      _db.budgetsTable,
    )..where((tbl) => tbl.id.equals(budget.id))).write(
      BudgetsTableCompanion(
        categoryId: Value(budget.categoryId),
        amountCents: Value(budget.amountCents),
        period: Value(budget.period.name),
      ),
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    await (_db.delete(
      _db.budgetsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }
}
