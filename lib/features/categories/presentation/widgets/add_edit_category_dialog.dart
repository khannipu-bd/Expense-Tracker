import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/category_icon_badge.dart';
import '../../domain/entities/category_entity.dart';

class AddEditCategoryDialog extends ConsumerStatefulWidget {
  final CategoryEntity? category;

  const AddEditCategoryDialog({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryDialog> createState() =>
      _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TransactionType _selectedType;
  late String _selectedIcon;
  late int _selectedColor;

  static const List<String> _iconOptions = [
    'restaurant',
    'directions_car',
    'shopping_bag',
    'receipt_long',
    'home',
    'medical_services',
    'school',
    'movie',
    'flight',
    'face',
    'people',
    'payments',
    'work',
    'store',
    'trending_up',
    'card_giftcard',
    'account_balance_wallet',
    'more_horiz',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedType = widget.category?.type ?? TransactionType.expense;
    _selectedIcon = widget.category?.iconName ?? 'shopping_bag';
    _selectedColor =
        widget.category?.colorValue ??
        AppColors.categoryPalette.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();

    if (widget.category == null) {
      final newCat = CategoryEntity(
        id: 'cat_${const Uuid().v4()}',
        name: _nameController.text.trim(),
        iconName: _selectedIcon,
        colorValue: _selectedColor,
        type: _selectedType,
        isDefault: false,
        isArchived: false,
        createdAt: now,
      );
      await repo.addCategory(newCat);
    } else {
      final updatedCat = widget.category!.copyWith(
        name: _nameController.text.trim(),
        iconName: _selectedIcon,
        colorValue: _selectedColor,
        type: _selectedType,
      );
      await repo.updateCategory(updatedCat);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.category == null ? 'Add Category' : 'Edit Category',
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Groceries',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                  selected: {_selectedType},
                  onSelectionChanged: (set) {
                    setState(() => _selectedType = set.first);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Icon',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                width: double.maxFinite,
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final iconName = _iconOptions[index];
                    final isSelected = iconName == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = iconName),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: CategoryIconBadge(
                          iconName: iconName,
                          colorValue: _selectedColor,
                          size: 36,
                          iconSize: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.categoryPalette.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final color = AppColors.categoryPalette[index];
                    final colorVal = color.toARGB32();
                    final isSelected = colorVal == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorVal),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
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
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
