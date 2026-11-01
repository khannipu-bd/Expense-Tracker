import '../../../../core/constants/app_constants.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class DashboardSummary {
  final FilterPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalBalanceCents; // Opening balance + total income - total expense
  final int periodIncomeCents;
  final int periodExpenseCents;
  final int netCashFlowCents;
  final int overallRemainingBudgetCents;
  final int dailyLimitCents;
  final int spentTodayCents;
  final bool hasMonthlyBudget;
  final List<TransactionEntity> recentTransactions;
  final List<CategoryExpenseSummary> topCategoryExpenses;

  const DashboardSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalBalanceCents,
    required this.periodIncomeCents,
    required this.periodExpenseCents,
    required this.netCashFlowCents,
    required this.overallRemainingBudgetCents,
    required this.dailyLimitCents,
    required this.spentTodayCents,
    required this.hasMonthlyBudget,
    required this.recentTransactions,
    required this.topCategoryExpenses,
  });
}

class CategoryExpenseSummary {
  final String categoryId;
  final String categoryName;
  final String iconName;
  final int colorValue;
  final int totalCents;
  final double percentage;

  const CategoryExpenseSummary({
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.colorValue,
    required this.totalCents,
    required this.percentage,
  });
}

abstract class DashboardRepository {
  Stream<DashboardSummary> watchDashboardSummary(FilterPeriod period);
}
