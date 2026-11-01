import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/repositories/report_repository.dart';

class TrendLineChart extends StatelessWidget {
  final List<DailyTrendPoint> trends;
  final String currencySymbol;

  const TrendLineChart({
    super.key,
    required this.trends,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Center(child: Text('No trend data available.'));
    }

    final spots = <FlSpot>[];
    double maxY = 0;

    for (int i = 0; i < trends.length; i++) {
      final expDouble = trends[i].expenseCents / 100.0;
      spots.add(FlSpot(i.toDouble(), expDouble));
      if (expDouble > maxY) maxY = expDouble;
    }

    return AspectRatio(
      aspectRatio: 1.8,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final idx = spot.x.toInt();
                  final point = trends[idx];
                  final expFormatted = CurrencyFormatter.formatCents(
                    point.expenseCents,
                    currencySymbol: currencySymbol,
                  );
                  return LineTooltipItem(
                    'Day ${point.date.day}\n$expFormatted',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
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
                reservedSize: 22,
                interval: (trends.length / 5).clamp(1.0, 30.0),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < trends.length) {
                    return Text(
                      '${trends[idx].date.day}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (trends.length - 1).toDouble(),
          minY: 0,
          maxY: (maxY * 1.2) > 0 ? (maxY * 1.2) : 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.expenseRed,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.expenseRed.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
