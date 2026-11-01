import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../budgets/domain/entities/budget_entity.dart';
import '../../../budgets/domain/repositories/budget_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final TransactionRepository _txRepo;
  final BudgetRepository _budgetRepo;
  final SettingsRepository _settingsRepo;

  DashboardRepositoryImpl(
    AppDatabase _,
    this._txRepo,
    this._budgetRepo,
    this._settingsRepo,
  );

  (DateTime, DateTime) _calculatePeriodDates(FilterPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case FilterPeriod.today:
        return (AppDateUtils.startOfDay(now), AppDateUtils.endOfDay(now));
      case FilterPeriod.thisWeek:
        return (AppDateUtils.startOfWeek(now), AppDateUtils.endOfWeek(now));
      case FilterPeriod.thisMonth:
        return (AppDateUtils.startOfMonth(now), AppDateUtils.endOfMonth(now));
      case FilterPeriod.thisYear:
        return (AppDateUtils.startOfYear(now), AppDateUtils.endOfYear(now));
      case FilterPeriod.custom:
        return (AppDateUtils.startOfMonth(now), AppDateUtils.endOfMonth(now));
    }
  }

  @override
  Stream<DashboardSummary> watchDashboardSummary(FilterPeriod period) async* {
    final settings = await _settingsRepo.getSettings();
    final (startDate, endDate) = _calculatePeriodDates(period);

    // Watch transactions and calculate totals
    final stream = _txRepo.watchFilteredTransactions(
      const TransactionFilter(sortBy: 'date_desc'),
    );

    await for (final allTxs in stream) {
      int lifetimeIncome = 0;
      int lifetimeExpense = 0;
      int periodIncome = 0;
      int periodExpense = 0;

      final categoryTotals = <String, (CategoryEntity, int)>{};

      for (final tx in allTxs) {
        if (tx.type == TransactionType.income) {
          lifetimeIncome += tx.amountCents;
          if (tx.date.isAfter(
                startDate.subtract(const Duration(milliseconds: 1)),
              ) &&
              tx.date.isBefore(endDate.add(const Duration(milliseconds: 1)))) {
            periodIncome += tx.amountCents;
          }
        } else {
          lifetimeExpense += tx.amountCents;
          if (tx.date.isAfter(
                startDate.subtract(const Duration(milliseconds: 1)),
              ) &&
              tx.date.isBefore(endDate.add(const Duration(milliseconds: 1)))) {
            periodExpense += tx.amountCents;

            if (tx.category != null) {
              final cat = tx.category!;
              final current = categoryTotals[cat.id]?.$2 ?? 0;
              categoryTotals[cat.id] = (cat, current + tx.amountCents);
            }
          }
        }
      }

      final totalBalanceCents =
          settings.openingBalanceCents + lifetimeIncome - lifetimeExpense;
      final netCashFlowCents = periodIncome - periodExpense;

      // Calculate spent today
      int spentTodayCents = 0;
      for (final tx in allTxs) {
        if (tx.type == TransactionType.expense &&
            AppDateUtils.isToday(tx.date)) {
          spentTodayCents += tx.amountCents;
        }
      }

      // Overall remaining budget & Daily limit calculation
      int remainingBudgetCents = 0;
      final budgets = await _budgetRepo.getAllBudgets();
      final overallBudget = budgets.firstWhere(
        (b) => b.isOverallBudget,
        orElse: () => BudgetEntity(
          id: '',
          amountCents: 0,
          period: BudgetPeriod.monthly,
          createdAt: DateTime.now(),
        ),
      );

      final bool hasMonthlyBudget = overallBudget.id.isNotEmpty;
      int dailyLimitCents = 0;

      if (hasMonthlyBudget) {
        remainingBudgetCents = overallBudget.remainingCents;
        final now = DateTime.now();
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
        final remainingDays = (lastDayOfMonth - now.day + 1);
        final remainingDaysCount = remainingDays > 0 ? remainingDays : 1;
        dailyLimitCents = remainingBudgetCents > 0
            ? (remainingBudgetCents / remainingDaysCount).round()
            : 0;
      }

      // Top category expenses sorted
      final topCategoriesList = categoryTotals.values.map((pair) {
        final cat = pair.$1;
        final total = pair.$2;
        final pct = periodExpense > 0 ? (total / periodExpense) : 0.0;
        return CategoryExpenseSummary(
          categoryId: cat.id,
          categoryName: cat.name,
          iconName: cat.iconName,
          colorValue: cat.colorValue,
          totalCents: total,
          percentage: pct,
        );
      }).toList()..sort((a, b) => b.totalCents.compareTo(a.totalCents));

      final recentTxs = allTxs.take(6).toList();

      yield DashboardSummary(
        period: period,
        startDate: startDate,
        endDate: endDate,
        totalBalanceCents: totalBalanceCents,
        periodIncomeCents: periodIncome,
        periodExpenseCents: periodExpense,
        netCashFlowCents: netCashFlowCents,
        overallRemainingBudgetCents: remainingBudgetCents,
        dailyLimitCents: dailyLimitCents,
        spentTodayCents: spentTodayCents,
        hasMonthlyBudget: hasMonthlyBudget,
        recentTransactions: recentTxs,
        topCategoryExpenses: topCategoriesList,
      );
    }
  }
}
