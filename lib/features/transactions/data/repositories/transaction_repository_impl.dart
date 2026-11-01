import 'package:drift/drift.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _db;

  TransactionRepositoryImpl(this._db);

  TransactionEntity _mapRowToEntity(TypedResult row) {
    final txData = row.readTable(_db.transactionsTable);
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

    final paymentMethod = PaymentMethod.values.firstWhere(
      (m) => m.name == txData.paymentMethod || m.label == txData.paymentMethod,
      orElse: () => PaymentMethod.cash,
    );

    return TransactionEntity(
      id: txData.id,
      type: txData.type == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amountCents: txData.amountCents,
      categoryId: txData.categoryId,
      category: category,
      date: txData.date,
      paymentMethod: paymentMethod,
      note: txData.note,
      createdAt: txData.createdAt,
      updatedAt: txData.updatedAt,
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildFilteredQuery(
    TransactionFilter filter,
  ) {
    final query = _db.select(_db.transactionsTable).join([
      leftOuterJoin(
        _db.categoriesTable,
        _db.categoriesTable.id.equalsExp(_db.transactionsTable.categoryId),
      ),
    ]);

    if (filter.type != null) {
      final typeStr = filter.type == TransactionType.income
          ? 'income'
          : 'expense';
      query.where(_db.transactionsTable.type.equals(typeStr));
    }

    if (filter.categoryId != null && filter.categoryId!.isNotEmpty) {
      query.where(_db.transactionsTable.categoryId.equals(filter.categoryId!));
    }

    if (filter.paymentMethod != null) {
      query.where(
        _db.transactionsTable.paymentMethod.equals(filter.paymentMethod!.name),
      );
    }

    if (filter.startDate != null) {
      query.where(
        _db.transactionsTable.date.isBiggerOrEqualValue(filter.startDate!),
      );
    }

    if (filter.endDate != null) {
      query.where(
        _db.transactionsTable.date.isSmallerOrEqualValue(filter.endDate!),
      );
    }

    if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
      final term = '%${filter.searchQuery!.trim().toLowerCase()}%';
      query.where(
        _db.transactionsTable.note.lower().like(term) |
            _db.categoriesTable.name.lower().like(term),
      );
    }

    switch (filter.sortBy) {
      case 'date_asc':
        query.orderBy([OrderingTerm.asc(_db.transactionsTable.date)]);
        break;
      case 'amount_desc':
        query.orderBy([OrderingTerm.desc(_db.transactionsTable.amountCents)]);
        break;
      case 'amount_asc':
        query.orderBy([OrderingTerm.asc(_db.transactionsTable.amountCents)]);
        break;
      case 'date_desc':
      default:
        query.orderBy([OrderingTerm.desc(_db.transactionsTable.date)]);
        break;
    }

    return query;
  }

  @override
  Stream<List<TransactionEntity>> watchFilteredTransactions(
    TransactionFilter filter,
  ) {
    return _buildFilteredQuery(
      filter,
    ).watch().map((rows) => rows.map(_mapRowToEntity).toList());
  }

  @override
  Future<List<TransactionEntity>> getFilteredTransactions(
    TransactionFilter filter,
  ) async {
    final rows = await _buildFilteredQuery(filter).get();
    return rows.map(_mapRowToEntity).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    final query = _db.select(_db.transactionsTable).join([
      leftOuterJoin(
        _db.categoriesTable,
        _db.categoriesTable.id.equalsExp(_db.transactionsTable.categoryId),
      ),
    ])..where(_db.transactionsTable.id.equals(id));

    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRowToEntity(row);
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    await _db
        .into(_db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            id: transaction.id,
            type: transaction.type == TransactionType.income
                ? 'income'
                : 'expense',
            amountCents: transaction.amountCents,
            categoryId: transaction.categoryId,
            date: transaction.date,
            paymentMethod: transaction.paymentMethod.name,
            note: Value(transaction.note),
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
          ),
        );
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    await (_db.update(
      _db.transactionsTable,
    )..where((tbl) => tbl.id.equals(transaction.id))).write(
      TransactionsTableCompanion(
        type: Value(
          transaction.type == TransactionType.income ? 'income' : 'expense',
        ),
        amountCents: Value(transaction.amountCents),
        categoryId: Value(transaction.categoryId),
        date: Value(transaction.date),
        paymentMethod: Value(transaction.paymentMethod.name),
        note: Value(transaction.note),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await (_db.delete(
      _db.transactionsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<int> getTotalIncomeCents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = _db.select(_db.transactionsTable)
      ..where((tbl) => tbl.type.equals('income'));

    if (startDate != null) {
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
    }

    final rows = await query.get();
    return rows.fold<int>(0, (sum, item) => sum + item.amountCents);
  }

  @override
  Future<int> getTotalExpenseCents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = _db.select(_db.transactionsTable)
      ..where((tbl) => tbl.type.equals('expense'));

    if (startDate != null) {
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
    }

    final rows = await query.get();
    return rows.fold<int>(0, (sum, item) => sum + item.amountCents);
  }

  @override
  Future<int> getCategoryExpenseCents(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = _db.select(_db.transactionsTable)
      ..where(
        (tbl) =>
            tbl.categoryId.equals(categoryId) &
            tbl.type.equals('expense') &
            tbl.date.isBiggerOrEqualValue(startDate) &
            tbl.date.isSmallerOrEqualValue(endDate),
      );

    final rows = await query.get();
    return rows.fold<int>(0, (sum, item) => sum + item.amountCents);
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    return getFilteredTransactions(const TransactionFilter());
  }

  @override
  Future<void> deleteAllTransactions() async {
    await _db.delete(_db.transactionsTable).go();
  }
}
