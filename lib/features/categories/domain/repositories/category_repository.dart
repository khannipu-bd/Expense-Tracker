import '../../../../core/constants/app_constants.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> watchAllCategories();
  Future<List<CategoryEntity>> getCategoriesByType(TransactionType type);
  Future<CategoryEntity?> getCategoryById(String id);
  Future<void> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
  Future<int> getTransactionCountForCategory(String id);
}
