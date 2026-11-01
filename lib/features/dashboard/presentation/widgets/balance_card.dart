import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/summary_card.dart';

class BalanceCard extends StatelessWidget {
  final int totalBalanceCents;
  final int periodIncomeCents;
  final int periodExpenseCents;
  final int remainingBudgetCents;
  final String currencySymbol;
  final FilterPeriod period;

  const BalanceCard({
    super.key,
    required this.totalBalanceCents,
    required this.periodIncomeCents,
    required this.periodExpenseCents,
    required this.remainingBudgetCents,
    required this.currencySymbol,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNegative = totalBalanceCents < 0;
    final bool isDeficit = periodExpenseCents > periodIncomeCents;

    final String balanceText = isNegative
        ? '- ${CurrencyFormatter.formatCents(totalBalanceCents.abs(), currencySymbol: currencySymbol)}'
        : CurrencyFormatter.formatCents(
            totalBalanceCents,
            currencySymbol: currencySymbol,
          );

    return SummaryCard(
      backgroundColor: isNegative
          ? AppColors.expenseBg
          : Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.35),
      borderSide: isNegative
          ? const BorderSide(color: AppColors.expenseRed, width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isNegative
                      ? AppColors.expenseRed
                      : AppColors.textSecondaryLight,
                  fontWeight: isNegative ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isNegative
                      ? AppColors.expenseRed.withValues(alpha: 0.15)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isNegative
                        ? AppColors.expenseRed
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            balanceText,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isNegative ? AppColors.expenseRed : null,
            ),
          ),
          if (isNegative || isDeficit) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.expenseRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.expenseRed.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 16,
                    color: AppColors.expenseRed,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Deficit: Expenses exceeded income',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.expenseRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.incomeBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.incomeGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          CurrencyFormatter.formatCents(
                            periodIncomeCents,
                            currencySymbol: currencySymbol,
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.incomeGreen,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.expenseBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.expenseRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expenses',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          CurrencyFormatter.formatCents(
                            periodExpenseCents,
                            currencySymbol: currencySymbol,
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.expenseRed,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
