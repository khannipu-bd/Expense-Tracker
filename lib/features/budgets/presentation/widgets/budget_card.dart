import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/category_icon_badge.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../domain/entities/budget_entity.dart';
import 'add_edit_budget_dialog.dart';

class BudgetCard extends ConsumerWidget {
  final BudgetEntity budget;

  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final currencySymbol = settingsAsync.value?.currency.symbol ?? '৳';

    final title = budget.isOverallBudget
        ? 'Overall Total Budget'
        : (budget.category?.name ?? 'Category Budget');
    final iconName = budget.category?.iconName ?? 'account_balance_wallet';
    final colorValue =
        budget.category?.colorValue ??
        Theme.of(context).colorScheme.primary.toARGB32();

    final pct = budget.usagePercentage.clamp(0.0, 1.0);
    final usagePctStr = (budget.usagePercentage * 100).toStringAsFixed(1);

    Color progressColor = Theme.of(context).colorScheme.primary;
    if (budget.isExceeded) {
      progressColor = AppColors.expenseRed;
    } else if (budget.isWarning) {
      progressColor = Colors.orange;
    }

    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryIconBadge(iconName: iconName, colorValue: colorValue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Period: ${budget.period.displayName}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddEditBudgetDialog(budget: budget),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.expenseRed,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Budget?'),
                      content: Text(
                        'Are you sure you want to delete this $title?',
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
                        .read(budgetRepositoryProvider)
                        .deleteBudget(budget.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Spent: ${CurrencyFormatter.formatCents(budget.spentCents, currencySymbol: currencySymbol)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Limit: ${CurrencyFormatter.formatCents(budget.amountCents, currencySymbol: currencySymbol)}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: progressColor.withValues(alpha: 0.15),
              color: progressColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$usagePctStr% used',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  budget.isExceeded
                      ? 'Exceeded by ${CurrencyFormatter.formatCents(budget.spentCents - budget.amountCents, currencySymbol: currencySymbol)}'
                      : 'Remaining: ${CurrencyFormatter.formatCents(budget.remainingCents, currencySymbol: currencySymbol)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: budget.isExceeded
                        ? AppColors.expenseRed
                        : AppColors.textSecondaryLight,
                    fontWeight: budget.isExceeded
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
