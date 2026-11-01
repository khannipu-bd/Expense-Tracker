import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Stream<List<BudgetEntity>> watchAllBudgets();
  Future<List<BudgetEntity>> getAllBudgets();
  Future<BudgetEntity?> getBudgetById(String id);
  Future<void> addBudget(BudgetEntity budget);
  Future<void> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(String id);
}
