import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, double> data;
  final bool isCollection;

  const CategoryChart({
    super.key,
    required this.data,
    required this.isCollection,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No data',
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
      );
    }

    final total = data.values.fold<double>(0, (a, b) => a + b);
    final colors = <Color>[
      AppColors.primaryBlue,
      AppColors.successGreen,
      AppColors.warningOrange,
      AppColors.darkBlue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  for (var i = 0; i < entries.length; i++)
                    PieChartSectionData(
                      value: entries[i].value,
                      color: colors[i % colors.length],
                      radius: 64,
                      title: '${((entries[i].value / total) * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 160,
            child: ListView.separated(
              itemCount: entries.length,
              shrinkWrap: true,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final e = entries[index];
                return Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
