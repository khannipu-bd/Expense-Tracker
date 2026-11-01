import '../../../../core/constants/app_constants.dart';
import '../entities/transaction_entity.dart';

class TransactionFilter {
  final TransactionType? type;
  final String? categoryId;
  final PaymentMethod? paymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final String sortBy; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'

  const TransactionFilter({
    this.type,
    this.categoryId,
    this.paymentMethod,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.sortBy = 'date_desc',
  });

  TransactionFilter copyWith({
    TransactionType? type,
    String? categoryId,
    PaymentMethod? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? sortBy,
    bool clearType = false,
    bool clearCategory = false,
    bool clearPaymentMethod = false,
    bool clearDates = false,
    bool clearSearch = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      paymentMethod: clearPaymentMethod
          ? null
          : (paymentMethod ?? this.paymentMethod),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchFilteredTransactions(
    TransactionFilter filter,
  );
  Future<List<TransactionEntity>> getFilteredTransactions(
    TransactionFilter filter,
  );
  Future<TransactionEntity?> getTransactionById(String id);
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);

  // Total summary queries
  Future<int> getTotalIncomeCents({DateTime? startDate, DateTime? endDate});
  Future<int> getTotalExpenseCents({DateTime? startDate, DateTime? endDate});
  Future<int> getCategoryExpenseCents(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  );

  // Export/Import database operations
  Future<List<TransactionEntity>> getAllTransactions();
  Future<void> deleteAllTransactions();
}
