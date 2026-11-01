import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/report_repository.dart';

final reportPeriodProvider = StateProvider<FilterPeriod>(
  (ref) => FilterPeriod.thisMonth,
);

final customReportDateRangeProvider = StateProvider<(DateTime?, DateTime?)>(
  (ref) => (null, null),
);

final reportSummaryFutureProvider = FutureProvider<ReportSummary>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final customRange = ref.watch(customReportDateRangeProvider);
  final repo = ref.watch(reportRepositoryProvider);

  return repo.getReportSummary(
    period: period,
    customStartDate: customRange.$1,
    customEndDate: customRange.$2,
  );
});
