import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  final int totalIncomeCents;
  final int totalExpenseCents;
  final String currencySymbol;

  const IncomeExpenseBarChart({
    super.key,
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final incomeDouble = totalIncomeCents / 100.0;
    final expenseDouble = totalExpenseCents / 100.0;
    final maxVal = incomeDouble > expenseDouble ? incomeDouble : expenseDouble;
    final maxY = maxVal > 0 ? maxVal * 1.25 : 100.0;

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final isIncome = groupIndex == 0;
                final label = isIncome ? 'Total Income' : 'Total Expenses';
                final cents = (rod.toY * 100).round();
                return BarTooltipItem(
                  '$label\n${CurrencyFormatter.formatCents(cents, currencySymbol: currencySymbol)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: AppColors.incomeGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    case 1:
                      return const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Expenses',
                          style: TextStyle(
                            color: AppColors.expenseRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: incomeDouble,
                  color: AppColors.incomeGreen,
                  width: 36,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: AppColors.incomeGreen.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expenseDouble,
                  color: AppColors.expenseRed,
                  width: 36,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: AppColors.expenseRed.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
