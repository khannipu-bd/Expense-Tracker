import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/category_icon_badge.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/summary_card.dart';
import '../providers/report_providers.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/income_expense_bar_chart.dart';
import '../widgets/trend_line_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportSummaryFutureProvider);
    final selectedPeriod = ref.watch(reportPeriodProvider);
    final customRange = ref.watch(customReportDateRangeProvider);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final currencySymbol = settingsAsync.value?.currency.symbol ?? '৳';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Financial Reports')),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            SizedBox(
              height: 40,
              child: ListView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: FilterPeriod.values.map((p) {
                  final isSelected = selectedPeriod == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.displayName),
                      selected: isSelected,
                      onSelected: (_) async {
                        ref.read(reportPeriodProvider.notifier).state = p;
                        if (p == FilterPeriod.custom) {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            ref
                                .read(customReportDateRangeProvider.notifier)
                                .state = (
                              picked.start,
                              picked.end,
                            );
                          }
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            if (selectedPeriod == FilterPeriod.custom &&
                customRange.$1 != null &&
                customRange.$2 != null) ...[
              const SizedBox(height: 8),
              Text(
                'Custom Range: ${DateFormatter.formatRange(customRange.$1!, customRange.$2!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),

            reportAsync.when(
              data: (summary) {
                final hasNoData =
                    summary.totalExpenseCents == 0 &&
                    summary.totalIncomeCents == 0;

                if (hasNoData) {
                  return const AppEmptyState(
                    icon: Icons.analytics_outlined,
                    title: 'No Data for This Period',
                    description:
                        'Select another period or add income and expenses to view reports.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StatCard(
                          title: 'Total Income',
                          value: CurrencyFormatter.formatCents(
                            summary.totalIncomeCents,
                            currencySymbol: currencySymbol,
                          ),
                          color: AppColors.incomeGreen,
                          icon: Icons.arrow_downward_rounded,
                        ),
                        _StatCard(
                          title: 'Total Expenses',
                          value: CurrencyFormatter.formatCents(
                            summary.totalExpenseCents,
                            currencySymbol: currencySymbol,
                          ),
                          color: AppColors.expenseRed,
                          icon: Icons.arrow_upward_rounded,
                        ),
                        _StatCard(
                          title: 'Net Cash Flow',
                          value: CurrencyFormatter.formatCents(
                            summary.netCashFlowCents,
                            currencySymbol: currencySymbol,
                          ),
                          color: summary.netCashFlowCents >= 0
                              ? AppColors.incomeGreen
                              : AppColors.expenseRed,
                          icon: Icons.account_balance_rounded,
                        ),
                        _StatCard(
                          title: 'Avg. Daily Spending',
                          value: CurrencyFormatter.formatDouble(
                            summary.averageDailySpendingCents / 100.0,
                            currencySymbol: currencySymbol,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                          icon: Icons.calendar_view_day_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Income vs Expense Bar Chart
                    SummaryCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Income vs. Expenses',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          IncomeExpenseBarChart(
                            totalIncomeCents: summary.totalIncomeCents,
                            totalExpenseCents: summary.totalExpenseCents,
                            currencySymbol: currencySymbol,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Breakdown Donut / Pie Chart
                    if (summary.categoryBreakdown.isNotEmpty) ...[
                      SummaryCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Breakdown',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            CategoryPieChart(
                              categoryData: summary.categoryBreakdown,
                              currencySymbol: currencySymbol,
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: summary.categoryBreakdown.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final cat = summary.categoryBreakdown[index];
                                final pct = (cat.percentage * 100)
                                    .toStringAsFixed(1);

                                return Row(
                                  children: [
                                    CategoryIconBadge(
                                      iconName: cat.iconName,
                                      colorValue: cat.colorValue,
                                      size: 32,
                                      iconSize: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        cat.categoryName,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatCents(
                                        cat.amountCents,
                                        currencySymbol: currencySymbol,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$pct%',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Spending Trend Line Chart
                    if (summary.dailyTrends.isNotEmpty) ...[
                      SummaryCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Spending Trend',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            TrendLineChart(
                              trends: summary.dailyTrends,
                              currencySymbol: currencySymbol,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const AppLoadingWidget(),
              error: (err, _) =>
                  AppErrorDisplayWidget(errorMessage: err.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
