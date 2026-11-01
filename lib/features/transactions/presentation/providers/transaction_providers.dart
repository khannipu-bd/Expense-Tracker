import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionFilterNotifierProvider =
    StateNotifierProvider<TransactionFilterNotifier, TransactionFilter>((ref) {
      return TransactionFilterNotifier();
    });

class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(const TransactionFilter());

  void setFilter(TransactionFilter newFilter) {
    state = newFilter;
  }

  void resetFilter() {
    state = const TransactionFilter();
  }
}

final filteredTransactionsStreamProvider =
    StreamProvider<List<TransactionEntity>>((ref) {
      final filter = ref.watch(transactionFilterNotifierProvider);
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.watchFilteredTransactions(filter);
    });

final singleTransactionFutureProvider =
    FutureProvider.family<TransactionEntity?, String>((ref, id) {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getTransactionById(id);
    });
