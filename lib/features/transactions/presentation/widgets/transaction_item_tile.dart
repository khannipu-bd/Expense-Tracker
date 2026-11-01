import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/category_icon_badge.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionItemTile extends ConsumerWidget {
  final TransactionEntity transaction;

  const TransactionItemTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final currencySymbol = settingsAsync.value?.currency.symbol ?? '৳';

    final categoryName = transaction.category?.name ?? 'Uncategorized';
    final iconName = transaction.category?.iconName ?? 'more_horiz';
    final colorValue =
        transaction.category?.colorValue ??
        AppColors.categoryPalette.first.toARGB32();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: () {
          context.push('/transaction-detail/${transaction.id}');
        },
        leading: CategoryIconBadge(iconName: iconName, colorValue: colorValue),
        title: Text(
          categoryName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              Text(
                transaction.note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  DateFormatter.formatTime(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.paymentMethod.label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: AmountText(
          amountCents: transaction.amountCents,
          currencySymbol: currencySymbol,
          type: transaction.type,
        ),
      ),
    );
  }
}
