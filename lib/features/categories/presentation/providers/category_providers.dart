import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/category_entity.dart';

final categoriesStreamProvider = StreamProvider<List<CategoryEntity>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAllCategories();
});

final categoriesByTypeProvider =
    FutureProvider.family<List<CategoryEntity>, TransactionType>((ref, type) {
      final repo = ref.watch(categoryRepositoryProvider);
      return repo.getCategoriesByType(type);
    });
