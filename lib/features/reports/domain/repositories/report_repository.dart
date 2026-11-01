import '../../../../core/constants/app_constants.dart';

class CategoryReportData {
  final String categoryId;
  final String categoryName;
  final String iconName;
  final int colorValue;
  final int amountCents;
  final double percentage;

  const CategoryReportData({
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.colorValue,
    required this.amountCents,
    required this.percentage,
  });
}

class DailyTrendPoint {
  final DateTime date;
  final int incomeCents;
  final int expenseCents;

  const DailyTrendPoint({
    required this.date,
    required this.incomeCents,
    required this.expenseCents,
  });
}

class ReportSummary {
  final FilterPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalIncomeCents;
  final int totalExpenseCents;
  final int netCashFlowCents;
  final double averageDailySpendingCents;
  final List<CategoryReportData> categoryBreakdown;
  final List<DailyTrendPoint> dailyTrends;

  const ReportSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.netCashFlowCents,
    required this.averageDailySpendingCents,
    required this.categoryBreakdown,
    required this.dailyTrends,
  });
}

abstract class ReportRepository {
  Future<ReportSummary> getReportSummary({
    required FilterPeriod period,
    DateTime? customStartDate,
    DateTime? customEndDate,
  });
}
