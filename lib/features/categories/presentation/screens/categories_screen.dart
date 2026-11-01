import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/category_icon_badge.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/category_providers.dart';
import '../widgets/add_edit_category_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: categoriesAsync.when(
          data: (categories) {
            final expenseCategories = categories
                .where((c) => c.type == TransactionType.expense)
                .toList();
            final incomeCategories = categories
                .where((c) => c.type == TransactionType.income)
                .toList();

            return TabBarView(
              children: [
                _CategoryList(categories: expenseCategories),
                _CategoryList(categories: incomeCategories),
              ],
            );
          },
          loading: () => const AppLoadingWidget(),
          error: (err, _) =>
              AppErrorDisplayWidget(errorMessage: err.toString()),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AddEditCategoryDialog(),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Category'),
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final List<dynamic> categories;

  const _CategoryList({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const AppEmptyState(
        icon: Icons.category_rounded,
        title: 'No Categories Found',
        description: 'Tap Add Category to create your first custom category.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          child: ListTile(
            leading: CategoryIconBadge(
              iconName: cat.iconName,
              colorValue: cat.colorValue,
            ),
            title: Text(
              cat.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: cat.isDefault
                ? const Text('Default Category', style: TextStyle(fontSize: 12))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddEditCategoryDialog(category: cat),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.expenseRed,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Category?'),
                        content: Text(
                          'Are you sure you want to delete "${cat.name}"? '
                          'If referenced by existing transactions, it will be safely archived to preserve your transaction history.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.expenseRed,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(categoryRepositoryProvider)
                          .deleteCategory(cat.id);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
