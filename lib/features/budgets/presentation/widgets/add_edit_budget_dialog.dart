import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/budget_entity.dart';

class AddEditBudgetDialog extends ConsumerStatefulWidget {
  final BudgetEntity? budget;

  const AddEditBudgetDialog({super.key, this.budget});

  @override
  ConsumerState<AddEditBudgetDialog> createState() =>
      _AddEditBudgetDialogState();
}

class _AddEditBudgetDialogState extends ConsumerState<AddEditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late BudgetPeriod _period;
  String? _selectedCategoryId; // null = overall total budget

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget == null
          ? ''
          : (widget.budget!.amountCents / 100.0).toStringAsFixed(2),
    );
    _period = widget.budget?.period ?? BudgetPeriod.monthly;
    _selectedCategoryId = widget.budget?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amountDouble = double.tryParse(_amountController.text.trim());
    if (amountDouble == null || amountDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    final repo = ref.read(budgetRepositoryProvider);
    final now = DateTime.now();

    if (widget.budget == null) {
      final newBudget = BudgetEntity(
        id: 'budget_${const Uuid().v4()}',
        categoryId: _selectedCategoryId,
        amountCents: CurrencyFormatter.doubleToCents(amountDouble),
        period: _period,
        createdAt: now,
      );
      await repo.addBudget(newBudget);
    } else {
      final updatedBudget = widget.budget!.copyWith(
        categoryId: _selectedCategoryId,
        amountCents: CurrencyFormatter.doubleToCents(amountDouble),
        period: _period,
      );
      await repo.updateBudget(updatedBudget);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final currencySymbol = settingsAsync.value?.currency.symbol ?? '৳';
    final categoriesAsync = ref.watch(
      categoriesByTypeProvider(TransactionType.expense),
    );

    return AlertDialog(
      title: Text(
        widget.budget == null ? 'Set Budget' : 'Edit Budget',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Period',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<BudgetPeriod>(
                  segments: const [
                    ButtonSegment(
                      value: BudgetPeriod.monthly,
                      label: Text('Monthly'),
                    ),
                    ButtonSegment(
                      value: BudgetPeriod.weekly,
                      label: Text('Weekly'),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (set) {
                    setState(() => _period = set.first);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('Scope', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<String?>(
                    isExpanded: true,
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      hintText: 'Select Budget Scope',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'Overall Total Budget',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...categories.map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(
                            'Category: ${cat.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                  );
                },
                loading: () => const CircularProgressIndicator.adaptive(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Spending Limit',
                  prefixText: '$currencySymbol ',
                  hintText: '0.00',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter spending limit';
                  }
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) {
                    return 'Enter valid amount greater than 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save Budget')),
      ],
    );
  }
}
