import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/category_icon_badge.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/transaction_providers.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singleTxAsync = ref.watch(
      singleTransactionFutureProvider(transactionId),
    );
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final currencySymbol = settingsAsync.value?.currency.symbol ?? '৳';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              context.push('/edit-transaction/$transactionId');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.expenseRed,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Transaction?'),
                  content: const Text(
                    'Are you sure you want to delete this transaction? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expenseRed,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref
                    .read(transactionRepositoryProvider)
                    .deleteTransaction(transactionId);
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: singleTxAsync.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found.'));
          }

          final categoryName = tx.category?.name ?? 'Uncategorized';
          final iconName = tx.category?.iconName ?? 'more_horiz';
          final colorValue =
              tx.category?.colorValue ??
              AppColors.categoryPalette.first.toARGB32();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                CategoryIconBadge(
                  iconName: iconName,
                  colorValue: colorValue,
                  size: 72,
                  iconSize: 36,
                ),
                const SizedBox(height: 16),
                Text(
                  categoryName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AmountText(
                  amountCents: tx.amountCents,
                  currencySymbol: currencySymbol,
                  type: tx.type,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Transaction Type',
                          value: tx.type.nameCapitalized,
                          valueColor: tx.type == TransactionType.income
                              ? AppColors.incomeGreen
                              : AppColors.expenseRed,
                        ),
                        const Divider(),
                        _DetailRow(
                          label: 'Date & Time',
                          value:
                              '${DateFormatter.formatFullDate(tx.date)} at ${DateFormatter.formatTime(tx.date)}',
                        ),
                        const Divider(),
                        _DetailRow(
                          label: 'Payment Method',
                          value: tx.paymentMethod.label,
                        ),
                        if (tx.note != null && tx.note!.isNotEmpty) ...[
                          const Divider(),
                          _DetailRow(
                            label: 'Note / Description',
                            value: tx.note!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (err, _) => AppErrorDisplayWidget(errorMessage: err.toString()),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
