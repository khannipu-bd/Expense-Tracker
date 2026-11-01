import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/category_icon_badge.dart';
import '../../domain/repositories/dashboard_repository.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<CategoryExpenseSummary> categoryExpenses;
  final String currencySymbol;

  const CategoryBreakdownWidget({
    super.key,
    required this.categoryExpenses,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Spending Categories',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categoryExpenses.length > 5 ? 5 : categoryExpenses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cat = categoryExpenses[index];
            final percentPct = (cat.percentage * 100).toStringAsFixed(1);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CategoryIconBadge(
                          iconName: cat.iconName,
                          colorValue: cat.colorValue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat.categoryName,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.formatCents(
                                cat.totalCents,
                                currencySymbol: currencySymbol,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$percentPct%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: cat.percentage.clamp(0.0, 1.0),
                        backgroundColor: Color(
                          cat.colorValue,
                        ).withValues(alpha: 0.2),
                        color: Color(cat.colorValue),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
