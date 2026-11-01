import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_entity.dart';

void main() {
  group('Budget Calculations Tests', () {
    test('Calculates remaining amount correctly', () {
      final budget = BudgetEntity(
        id: '1',
        amountCents: 10000, // $100.00
        spentCents: 4000, // $40.00
        period: BudgetPeriod.monthly,
        createdAt: DateTime.now(),
      );

      expect(budget.remainingCents, 6000); // $60.00 remaining
      expect(budget.usagePercentage, 0.40); // 40%
      expect(budget.isWarning, false);
      expect(budget.isExceeded, false);
    });

    test('Triggers warning threshold at 80%', () {
      final budget = BudgetEntity(
        id: '2',
        amountCents: 10000,
        spentCents: 8500, // 85%
        period: BudgetPeriod.monthly,
        createdAt: DateTime.now(),
      );

      expect(budget.usagePercentage, 0.85);
      expect(budget.isWarning, true);
      expect(budget.isExceeded, false);
    });

    test('Triggers exceeded flag when spent exceeds amount', () {
      final budget = BudgetEntity(
        id: '3',
        amountCents: 10000,
        spentCents: 12000, // 120%
        period: BudgetPeriod.monthly,
        createdAt: DateTime.now(),
      );

      expect(budget.remainingCents, -2000);
      expect(budget.usagePercentage, 1.20);
      expect(budget.isWarning, false);
      expect(budget.isExceeded, true);
    });

    test(
      'Zero budget amount handles usagePercentage safely without NaN or division by zero',
      () {
        final budget = BudgetEntity(
          id: '4',
          amountCents: 0,
          spentCents: 0,
          period: BudgetPeriod.monthly,
          createdAt: DateTime.now(),
        );

        expect(budget.usagePercentage, 0.0);
        expect(budget.remainingCents, 0);
      },
    );
  });
}
