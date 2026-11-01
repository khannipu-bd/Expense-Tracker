import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/repositories/report_repository.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategoryReportData> categoryData;
  final String currencySymbol;

  const CategoryPieChart({
    super.key,
    required this.categoryData,
    required this.currencySymbol,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryData.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No category spending for this period.')),
      );
    }

    final sections = List.generate(widget.categoryData.length, (i) {
      final isTouched = i == touchedIndex;
      final item = widget.categoryData[i];
      final fontSize = isTouched ? 14.0 : 11.0;
      final radius = isTouched ? 65.0 : 55.0;
      final color = Color(item.colorValue);

      final pct = item.percentage * 100;
      final title = pct >= 4.0 ? '${pct.toStringAsFixed(0)}%' : '';

      return PieChartSectionData(
        color: color,
        value: item.amountCents.toDouble(),
        title: title,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });

    final selectedCategory =
        (touchedIndex >= 0 && touchedIndex < widget.categoryData.length)
        ? widget.categoryData[touchedIndex]
        : null;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 45,
                  sections: sections,
                ),
              ),
              if (selectedCategory != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedCategory.categoryName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      CurrencyFormatter.formatCents(
                        selectedCategory.amountCents,
                        currencySymbol: widget.currencySymbol,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(selectedCategory.colorValue),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Wrap color-coded legend chips
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: widget.categoryData.map((item) {
            final color = Color(item.colorValue);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(item.categoryName, style: const TextStyle(fontSize: 11)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
