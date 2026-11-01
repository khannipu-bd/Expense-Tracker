import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardPeriodStateProvider = StateProvider<FilterPeriod>(
  (ref) => FilterPeriod.thisMonth,
);

final dashboardSummaryStreamProvider = StreamProvider<DashboardSummary>((ref) {
  final period = ref.watch(dashboardPeriodStateProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchDashboardSummary(period);
});
