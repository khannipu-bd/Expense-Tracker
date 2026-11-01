import '../../../../core/constants/app_constants.dart';
import '../../../categories/domain/entities/category_entity.dart';

class BudgetEntity {
  final String id;
  final String? categoryId; // null for total budget
  final CategoryEntity? category;
  final int amountCents;
  final BudgetPeriod period;
  final DateTime createdAt;
  final int spentCents;

  const BudgetEntity({
    required this.id,
    this.categoryId,
    this.category,
    required this.amountCents,
    required this.period,
    required this.createdAt,
    this.spentCents = 0,
  });

  bool get isOverallBudget => categoryId == null;

  int get remainingCents => amountCents - spentCents;

  double get usagePercentage {
    if (amountCents <= 0) return 0.0;
    return spentCents / amountCents;
  }

  bool get isExceeded => spentCents > amountCents;

  bool get isWarning =>
      !isExceeded && usagePercentage >= AppConstants.budgetWarningThreshold;

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    CategoryEntity? category,
    int? amountCents,
    BudgetPeriod? period,
    DateTime? createdAt,
    int? spentCents,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      amountCents: amountCents ?? this.amountCents,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      spentCents: spentCents ?? this.spentCents,
    );
  }
}
