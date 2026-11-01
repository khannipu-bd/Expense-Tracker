import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../providers/transaction_providers.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  ConsumerState<TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState
    extends ConsumerState<TransactionFilterSheet> {
  late TransactionType? _type;
  late String? _categoryId;
  late PaymentMethod? _paymentMethod;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    final current = ref.read(transactionFilterNotifierProvider);
    _type = current.type;
    _categoryId = current.categoryId;
    _paymentMethod = current.paymentMethod;
    _startDate = current.startDate;
    _endDate = current.endDate;
    _sortBy = current.sortBy;
  }

  void _apply() {
    final newFilter = TransactionFilter(
      type: _type,
      categoryId: _categoryId,
      paymentMethod: _paymentMethod,
      startDate: _startDate,
      endDate: _endDate,
      sortBy: _sortBy,
    );
    ref.read(transactionFilterNotifierProvider.notifier).setFilter(newFilter);
    Navigator.of(context).pop();
  }

  void _reset() {
    ref.read(transactionFilterNotifierProvider.notifier).resetFilter();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: _reset, child: const Text('Reset All')),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      'Sort By',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Newest First'),
                          selected: _sortBy == 'date_desc',
                          onSelected: (_) =>
                              setState(() => _sortBy = 'date_desc'),
                        ),
                        ChoiceChip(
                          label: const Text('Oldest First'),
                          selected: _sortBy == 'date_asc',
                          onSelected: (_) =>
                              setState(() => _sortBy = 'date_asc'),
                        ),
                        ChoiceChip(
                          label: const Text('Highest Amount'),
                          selected: _sortBy == 'amount_desc',
                          onSelected: (_) =>
                              setState(() => _sortBy = 'amount_desc'),
                        ),
                        ChoiceChip(
                          label: const Text('Lowest Amount'),
                          selected: _sortBy == 'amount_asc',
                          onSelected: (_) =>
                              setState(() => _sortBy = 'amount_asc'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Transaction Type',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _type == null,
                          onSelected: (_) => setState(() => _type = null),
                        ),
                        ChoiceChip(
                          label: const Text('Expense'),
                          selected: _type == TransactionType.expense,
                          onSelected: (_) =>
                              setState(() => _type = TransactionType.expense),
                        ),
                        ChoiceChip(
                          label: const Text('Income'),
                          selected: _type == TransactionType.income,
                          onSelected: (_) =>
                              setState(() => _type = TransactionType.income),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      data: (categories) {
                        final filteredCategories = _type == null
                            ? categories
                            : categories.where((c) => c.type == _type).toList();

                        return DropdownButtonFormField<String?>(
                          initialValue: _categoryId,
                          decoration: const InputDecoration(
                            hintText: 'Select Category',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            ...filteredCategories.map(
                              (cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() => _categoryId = val),
                        );
                      },
                      loading: () => const CircularProgressIndicator.adaptive(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _paymentMethod == null,
                          onSelected: (_) =>
                              setState(() => _paymentMethod = null),
                        ),
                        ...PaymentMethod.values.map(
                          (pm) => ChoiceChip(
                            label: Text(pm.label),
                            selected: _paymentMethod == pm,
                            onSelected: (_) =>
                                setState(() => _paymentMethod = pm),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Date Range',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (date != null) {
                                setState(() => _startDate = date);
                              }
                            },
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                            ),
                            label: Text(
                              _startDate == null
                                  ? 'From Date'
                                  : DateFormatter.formatShortDate(_startDate!),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (date != null) {
                                setState(() => _endDate = date);
                              }
                            },
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                            ),
                            label: Text(
                              _endDate == null
                                  ? 'To Date'
                                  : DateFormatter.formatShortDate(_endDate!),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply Filter'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
