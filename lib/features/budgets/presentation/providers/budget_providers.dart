import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/budget_entity.dart';

final budgetsStreamProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchAllBudgets();
});
