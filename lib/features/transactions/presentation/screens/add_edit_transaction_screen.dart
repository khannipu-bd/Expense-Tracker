import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/category_icon_badge.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_providers.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  final String? initialType;

  const AddEditTransactionScreen({
    super.key,
    this.transactionId,
    this.initialType,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late TransactionType _type;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  CategoryEntity? _selectedCategory;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();

    if (widget.initialType == 'income') {
      _type = TransactionType.income;
    } else {
      _type = TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _populateExistingData(TransactionEntity tx) {
    if (_isLoaded) return;
    _isLoaded = true;
    _type = tx.type;
    _amountController.text = (tx.amountCents / 100.0).toStringAsFixed(2);
    _noteController.text = tx.note ?? '';
    _selectedDate = tx.date;
    _selectedTime = TimeOfDay.fromDateTime(tx.date);
    _paymentMethod = tx.paymentMethod;
    _selectedCategory = tx.category;
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final amountDouble = double.tryParse(_amountController.text.trim());
    if (amountDouble == null || amountDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime?.hour ?? 12,
        _selectedTime?.minute ?? 0,
      );

      final now = DateTime.now();

      if (widget.transactionId == null) {
        final newTx = TransactionEntity(
          id: 'tx_${const Uuid().v4()}',
          type: _type,
          amountCents: CurrencyFormatter.doubleToCents(amountDouble),
          categoryId: _selectedCategory!.id,
          category: _selectedCategory,
          date: finalDateTime,
          paymentMethod: _paymentMethod,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.addTransaction(newTx);
      } else {
        final updatedTx = TransactionEntity(
          id: widget.transactionId!,
          type: _type,
          amountCents: CurrencyFormatter.doubleToCents(amountDouble),
          categoryId: _selectedCategory!.id,
          category: _selectedCategory,
          date: finalDateTime,
          paymentMethod: _paymentMethod,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.updateTransaction(updatedTx);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save transaction: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final currencySymbol = settingsAsync.value?.currency.symbol ?? '৳';
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type));

    if (widget.transactionId != null && !_isLoaded) {
      final singleTxAsync = ref.watch(
        singleTransactionFutureProvider(widget.transactionId!),
      );
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('Edit Transaction')),
        body: singleTxAsync.when(
          data: (tx) {
            if (tx != null) _populateExistingData(tx);
            return _buildForm(context, currencySymbol, categoriesAsync);
          },
          loading: () => const AppLoadingWidget(),
          error: (err, _) => Center(child: Text(err.toString())),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.transactionId == null ? 'Add Transaction' : 'Edit Transaction',
        ),
      ),
      body: _buildForm(context, currencySymbol, categoriesAsync),
    );
  }

  Widget _buildForm(
    BuildContext context,
    String currencySymbol,
    AsyncValue<List<CategoryEntity>> categoriesAsync,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Segmented Button
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (set) {
                  setState(() {
                    _type = set.first;
                    _selectedCategory = null; // reset category on type switch
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Amount Input
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$currencySymbol ',
                hintText: '0.00',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter amount';
                }
                final numVal = double.tryParse(val.trim());
                if (numVal == null || numVal <= 0) {
                  return 'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Category Selector
            Text('Category', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Text(
                    'No categories found for this type. Please create one in Settings.',
                  );
                }
                if (_selectedCategory == null && categories.isNotEmpty) {
                  _selectedCategory = categories.first;
                }

                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategory?.id == cat.id;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: CategoryIconBadge(
                                iconName: cat.iconName,
                                colorValue: cat.colorValue,
                                size: 48,
                                iconSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 64,
                              child: Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const CircularProgressIndicator.adaptive(),
              error: (err, _) => Text(err.toString()),
            ),
            const SizedBox(height: 16),

            // Payment Method
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PaymentMethod.values.map((pm) {
                final isSelected = _paymentMethod == pm;
                return ChoiceChip(
                  label: Text(pm.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _paymentMethod = pm),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date & Time Picker
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(
                      DateFormatter.formatShortDate(_selectedDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                    icon: const Icon(Icons.access_time_rounded, size: 18),
                    label: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select Time',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Note Input
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note / Description (Optional)',
                hintText: 'e.g., Dinner with friends',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator.adaptive()
                    : Text(
                        widget.transactionId == null
                            ? 'Save Transaction'
                            : 'Update Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
