import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/budget_providers.dart';
import '../widgets/add_edit_budget_dialog.dart';
import '../widgets/budget_card.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Budget Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Budget',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditBudgetDialog(),
              );
            },
          ),
        ],
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return AppEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No Budgets Configured',
              description:
                  'Set up spending limits for overall or category expenses to stay on track.',
              buttonLabel: 'Create New Budget',
              onButtonPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddEditBudgetDialog(),
                );
              },
            );
          }

          return ListView.separated(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80,
            ),
            itemCount: budgets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return BudgetCard(budget: budget);
            },
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (err, _) => AppErrorDisplayWidget(errorMessage: err.toString()),
      ),
    );
  }
}
