import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../transactions/presentation/widgets/transaction_item_tile.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/daily_limit_card.dart';
import '../widgets/category_breakdown_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryStreamProvider);
    final currentPeriod = ref.watch(dashboardPeriodStateProvider);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final currencySymbol = settingsAsync.value?.currency.symbol ?? '৳';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              DateFormatter.formatFullDate(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: summaryAsync.when(
        data: (summary) {
          final hasNoTransactions =
              summary.recentTransactions.isEmpty &&
              summary.periodExpenseCents == 0 &&
              summary.periodIncomeCents == 0;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardSummaryStreamProvider);
            },
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children:
                          [
                            FilterPeriod.today,
                            FilterPeriod.thisWeek,
                            FilterPeriod.thisMonth,
                            FilterPeriod.thisYear,
                          ].map((period) {
                            final isSelected = currentPeriod == period;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(period.displayName),
                                selected: isSelected,
                                onSelected: (_) {
                                  ref
                                          .read(
                                            dashboardPeriodStateProvider
                                                .notifier,
                                          )
                                          .state =
                                      period;
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Balance Summary Card
                  BalanceCard(
                    totalBalanceCents: summary.totalBalanceCents,
                    periodIncomeCents: summary.periodIncomeCents,
                    periodExpenseCents: summary.periodExpenseCents,
                    remainingBudgetCents: summary.overallRemainingBudgetCents,
                    currencySymbol: currencySymbol,
                    period: currentPeriod,
                  ),
                  const SizedBox(height: 12),

                  // Daily Spending Limit Card
                  DailyLimitCard(
                    dailyLimitCents: summary.dailyLimitCents,
                    spentTodayCents: summary.spentTodayCents,
                    hasMonthlyBudget: summary.hasMonthlyBudget,
                    currencySymbol: currencySymbol,
                  ),
                  const SizedBox(height: 16),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/add-transaction', extra: 'expense');
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.expenseRed,
                          ),
                          label: const Text(
                            'Add Expense',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppColors.expenseBg,
                            foregroundColor: AppColors.expenseRed,
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/add-transaction', extra: 'income');
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.incomeGreen,
                          ),
                          label: const Text(
                            'Add Income',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppColors.incomeBg,
                            foregroundColor: AppColors.incomeGreen,
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (hasNoTransactions) ...[
                    AppEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No Transactions Yet',
                      description:
                          'Start tracking your expenses and income to see detailed financial insights.',
                      buttonLabel: 'Add Your First Transaction',
                      onButtonPressed: () {
                        context.push('/add-transaction');
                      },
                    ),
                  ] else ...[
                    // Category Breakdown
                    CategoryBreakdownWidget(
                      categoryExpenses: summary.topCategoryExpenses,
                      currencySymbol: currencySymbol,
                    ),
                    const SizedBox(height: 24),

                    // Recent Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/transactions');
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Recent Transactions List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summary.recentTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = summary.recentTransactions[index];
                        return TransactionItemTile(transaction: tx);
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (err, _) => AppErrorDisplayWidget(errorMessage: err.toString()),
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
