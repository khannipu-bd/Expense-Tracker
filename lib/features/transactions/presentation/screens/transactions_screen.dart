import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../widgets/transaction_item_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final current = ref.read(transactionFilterNotifierProvider);
    ref
        .read(transactionFilterNotifierProvider.notifier)
        .setFilter(current.copyWith(searchQuery: query));
  }

  @override
  Widget build(BuildContext context) {
    final txsAsync = ref.watch(filteredTransactionsStreamProvider);
    final filter = ref.watch(transactionFilterNotifierProvider);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final currencySymbol = settingsAsync.value?.currency.symbol ?? '৳';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const TransactionFilterSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search note or category...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (filter.type != null ||
              filter.categoryId != null ||
              filter.paymentMethod != null ||
              filter.startDate != null ||
              filter.endDate != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Filters active',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref
                          .read(transactionFilterNotifierProvider.notifier)
                          .resetFilter();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.expenseRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: txsAsync.when(
              data: (txs) {
                if (txs.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No Transactions Found',
                    description:
                        'Try clearing search/filters or add a new transaction.',
                    buttonLabel: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      ref
                          .read(transactionFilterNotifierProvider.notifier)
                          .resetFilter();
                    },
                  );
                }

                // Group by date
                final grouped = <String, List<TransactionEntity>>{};
                for (final tx in txs) {
                  final key = DateFormatter.formatDateGroupHeader(
                    AppDateUtils.startOfDay(tx.date),
                  );
                  grouped.putIfAbsent(key, () => []).add(tx);
                }

                return ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 80,
                  ),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final headerKey = grouped.keys.elementAt(index);
                    final groupTxs = grouped[headerKey]!;

                    int dayIncome = 0;
                    int dayExpense = 0;
                    for (final t in groupTxs) {
                      if (t.type == TransactionType.income) {
                        dayIncome += t.amountCents;
                      } else {
                        dayExpense += t.amountCents;
                      }
                    }

                    final netCents = dayIncome - dayExpense;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  headerKey,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Wrap(
                                spacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (dayIncome > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.incomeBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '+${CurrencyFormatter.formatCents(dayIncome, currencySymbol: currencySymbol)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.incomeGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (dayExpense > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.expenseBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '-${CurrencyFormatter.formatCents(dayExpense, currencySymbol: currencySymbol)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.expenseRed,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (dayIncome > 0 && dayExpense > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (netCents >= 0
                                                    ? AppColors.incomeGreen
                                                    : AppColors.expenseRed)
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Net: ${netCents >= 0 ? '+' : '-'}${CurrencyFormatter.formatCents(netCents.abs(), currencySymbol: currencySymbol)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: netCents >= 0
                                              ? AppColors.incomeGreen
                                              : AppColors.expenseRed,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ...groupTxs.map(
                          (t) => TransactionItemTile(transaction: t),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const AppLoadingWidget(),
              error: (err, _) =>
                  AppErrorDisplayWidget(errorMessage: err.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-transaction');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }
}
