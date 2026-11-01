import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/summary_card.dart';

class DailyLimitCard extends StatelessWidget {
  final int dailyLimitCents;
  final int spentTodayCents;
  final bool hasMonthlyBudget;
  final String currencySymbol;

  const DailyLimitCard({
    super.key,
    required this.dailyLimitCents,
    required this.spentTodayCents,
    required this.hasMonthlyBudget,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMonthlyBudget) {
      return SummaryCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Theme.of(context).cardColor,
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Set an overall monthly budget in Budgets tab to track your daily limit.',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final bool isExceeded = spentTodayCents > dailyLimitCents;
    final String limitStr = CurrencyFormatter.formatCents(
      dailyLimitCents,
      currencySymbol: currencySymbol,
    );
    final String spentStr = CurrencyFormatter.formatCents(
      spentTodayCents,
      currencySymbol: currencySymbol,
    );

    final cardBgColor = isExceeded
        ? AppColors.expenseBg
        : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2);
    final borderSide = isExceeded
        ? const BorderSide(color: AppColors.expenseRed, width: 1.5)
        : null;
    final iconColor = isExceeded
        ? AppColors.expenseRed
        : Theme.of(context).colorScheme.primary;

    return SummaryCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: cardBgColor,
      borderSide: borderSide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExceeded ? Icons.warning_amber_rounded : Icons.speed_rounded,
                color: iconColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isExceeded ? "Daily Limit Exceeded!" : "Today's Daily Limit",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isExceeded ? AppColors.expenseRed : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isExceeded) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.expenseRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'OVER LIMIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Today's Limit: $limitStr",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Spent Today: $spentStr",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isExceeded
                        ? AppColors.expenseRed
                        : AppColors.incomeGreen,
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
