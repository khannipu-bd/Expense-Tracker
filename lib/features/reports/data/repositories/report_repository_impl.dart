import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final TransactionRepository _txRepo;

  ReportRepositoryImpl(this._txRepo);

  (DateTime, DateTime) _resolvePeriodDates({
    required FilterPeriod period,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
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
        final start = AppDateUtils.startOfDay(customStart ?? now);
        final end = AppDateUtils.endOfDay(customEnd ?? now);
        return (start, end);
    }
  }

  @override
  Future<ReportSummary> getReportSummary({
    required FilterPeriod period,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async {
    final (startDate, endDate) = _resolvePeriodDates(
      period: period,
      customStart: customStartDate,
      customEnd: customEndDate,
    );

    final txs = await _txRepo.getFilteredTransactions(
      TransactionFilter(
        startDate: startDate,
        endDate: endDate,
        sortBy: 'date_asc',
      ),
    );

    int totalIncome = 0;
    int totalExpense = 0;
    final categoryTotalsMap = <String, (CategoryEntity, int)>{};
    final dailyTotalsMap =
        <String, (DateTime, int, int)>{}; // yyyy-MM-dd -> (date, inc, exp)

    // Pre-populate daily map with every single day in range for continuous charts
    var currentDay = AppDateUtils.startOfDay(startDate);
    final endDay = AppDateUtils.startOfDay(endDate);
    while (!currentDay.isAfter(endDay)) {
      final key = '${currentDay.year}-${currentDay.month}-${currentDay.day}';
      dailyTotalsMap[key] = (currentDay, 0, 0);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    for (final tx in txs) {
      final dayKey = '${tx.date.year}-${tx.date.month}-${tx.date.day}';
      final existingDay =
          dailyTotalsMap[dayKey] ?? (AppDateUtils.startOfDay(tx.date), 0, 0);

      if (tx.type == TransactionType.income) {
        totalIncome += tx.amountCents;
        dailyTotalsMap[dayKey] = (
          existingDay.$1,
          existingDay.$2 + tx.amountCents,
          existingDay.$3,
        );
      } else {
        totalExpense += tx.amountCents;
        dailyTotalsMap[dayKey] = (
          existingDay.$1,
          existingDay.$2,
          existingDay.$3 + tx.amountCents,
        );

        if (tx.category != null) {
          final cat = tx.category!;
          final currCatTotal = categoryTotalsMap[cat.id]?.$2 ?? 0;
          categoryTotalsMap[cat.id] = (cat, currCatTotal + tx.amountCents);
        }
      }
    }

    final categoryBreakdown = categoryTotalsMap.values.map((pair) {
      final cat = pair.$1;
      final amt = pair.$2;
      final pct = totalExpense > 0 ? (amt / totalExpense) : 0.0;
      return CategoryReportData(
        categoryId: cat.id,
        categoryName: cat.name,
        iconName: cat.iconName,
        colorValue: cat.colorValue,
        amountCents: amt,
        percentage: pct,
      );
    }).toList()..sort((a, b) => b.amountCents.compareTo(a.amountCents));

    final dailyTrends = dailyTotalsMap.values.map((tuple) {
      return DailyTrendPoint(
        date: tuple.$1,
        incomeCents: tuple.$2,
        expenseCents: tuple.$3,
      );
    }).toList();

    final dayCount = dailyTotalsMap.isNotEmpty ? dailyTotalsMap.length : 1;
    final avgDailySpending = totalExpense / dayCount;

    return ReportSummary(
      period: period,
      startDate: startDate,
      endDate: endDate,
      totalIncomeCents: totalIncome,
      totalExpenseCents: totalExpense,
      netCashFlowCents: totalIncome - totalExpense,
      averageDailySpendingCents: avgDailySpending,
      categoryBreakdown: categoryBreakdown,
      dailyTrends: dailyTrends,
    );
  }
}
