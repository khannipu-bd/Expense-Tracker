import 'package:drift/drift.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  CategoryEntity _mapDataToEntity(CategoryTableData data) {
    return CategoryEntity(
      id: data.id,
      name: data.name,
      iconName: data.iconName,
      colorValue: data.colorValue,
      type: data.type == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      isDefault: data.isDefault,
      isArchived: data.isArchived,
      createdAt: data.createdAt,
    );
  }

  @override
  Stream<List<CategoryEntity>> watchAllCategories() {
    return (_db.select(_db.categoriesTable)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch()
        .map((rows) => rows.map(_mapDataToEntity).toList());
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByType(TransactionType type) async {
    final typeStr = type == TransactionType.income ? 'income' : 'expense';
    final rows =
        await (_db.select(_db.categoriesTable)
              ..where(
                (tbl) =>
                    tbl.type.equals(typeStr) & tbl.isArchived.equals(false),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
            .get();
    return rows.map(_mapDataToEntity).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    final query = _db.select(_db.categoriesTable)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapDataToEntity(row);
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    await _db
        .into(_db.categoriesTable)
        .insert(
          CategoriesTableCompanion.insert(
            id: category.id,
            name: category.name,
            iconName: category.iconName,
            colorValue: category.colorValue,
            type: category.type == TransactionType.income
                ? 'income'
                : 'expense',
            isDefault: Value(category.isDefault),
            isArchived: Value(category.isArchived),
            createdAt: category.createdAt,
          ),
        );
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    await (_db.update(
      _db.categoriesTable,
    )..where((tbl) => tbl.id.equals(category.id))).write(
      CategoriesTableCompanion(
        name: Value(category.name),
        iconName: Value(category.iconName),
        colorValue: Value(category.colorValue),
        type: Value(
          category.type == TransactionType.income ? 'income' : 'expense',
        ),
      ),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    // Check if referenced by transactions
    final txCount = await getTransactionCountForCategory(id);
    if (txCount > 0) {
      // Soft-delete (archive) to preserve historical transactions and categories
      await (_db.update(_db.categoriesTable)..where((tbl) => tbl.id.equals(id)))
          .write(const CategoriesTableCompanion(isArchived: Value(true)));
    } else {
      // Hard delete if unused
      await (_db.delete(
        _db.categoriesTable,
      )..where((tbl) => tbl.id.equals(id))).go();
    }
  }

  @override
  Future<int> getTransactionCountForCategory(String id) async {
    final query = _db.select(_db.transactionsTable)
      ..where((tbl) => tbl.categoryId.equals(id));
    final rows = await query.get();
    return rows.length;
  }
}
