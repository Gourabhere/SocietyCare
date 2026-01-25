import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../../utils/date_formatter_utils.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(pujaTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickRange,
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final filtered = _applyRange(transactions);
          final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

          final collectionsByCat = <String, double>{};
          final expensesByCat = <String, double>{};
          for (final t in filtered) {
            final target = t.type == PujaTransactionType.collection ? collectionsByCat : expensesByCat;
            target[t.category] = (target[t.category] ?? 0) + t.amount;
          }

          final series = _buildDailySeries(filtered);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_range != null)
                Text(
                  '${DateFormatterUtils.formatUi(_range!.start)} - ${DateFormatterUtils.formatUi(_range!.end)}',
                  style: const TextStyle(color: AppColors.textGrey),
                ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Collections vs Expenses (daily)',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 260,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 48,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      currency.format(value).replaceAll('.00', ''),
                                      style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (series.length / 4).clamp(1, double.infinity),
                                  getTitlesWidget: (value, meta) {
                                    final i = value.toInt();
                                    if (i < 0 || i >= series.length) return const SizedBox.shrink();
                                    return Text(
                                      DateFormat('d/M').format(series[i].date),
                                      style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (var i = 0; i < series.length; i++)
                                    FlSpot(i.toDouble(), series[i].collections),
                                ],
                                isCurved: true,
                                color: AppColors.successGreen,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                              ),
                              LineChartBarData(
                                spots: [
                                  for (var i = 0; i < series.length; i++)
                                    FlSpot(i.toDouble(), series[i].expenses),
                                ],
                                isCurved: true,
                                color: AppColors.errorRed,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          _LegendDot(color: AppColors.successGreen, label: 'Collections'),
                          SizedBox(width: 16),
                          _LegendDot(color: AppColors.errorRed, label: 'Expenses'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Collections by Category',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      CategoryChart(data: collectionsByCat, isCollection: true),
                      const Divider(height: 32),
                      const Text(
                        'Expenses by Category',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      CategoryChart(data: expensesByCat, isCollection: false),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load analytics: $e',
              style: const TextStyle(color: AppColors.errorRed),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  List<PujaTransaction> _applyRange(List<PujaTransaction> list) {
    if (_range == null) return list;
    final start = DateTime(_range!.start.year, _range!.start.month, _range!.start.day);
    final end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day);
    return list.where((t) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      return (d.isAtSameMomentAs(start) || d.isAfter(start)) &&
          (d.isAtSameMomentAs(end) || d.isBefore(end));
    }).toList();
  }

  List<_DailyPoint> _buildDailySeries(List<PujaTransaction> list) {
    if (list.isEmpty) {
      final today = DateTime.now();
      return [
        _DailyPoint(date: DateTime(today.year, today.month, today.day), collections: 0, expenses: 0),
      ];
    }

    final sorted = [...list]..sort((a, b) => a.date.compareTo(b.date));
    final start = DateTime(sorted.first.date.year, sorted.first.date.month, sorted.first.date.day);
    final end = DateTime(sorted.last.date.year, sorted.last.date.month, sorted.last.date.day);

    final days = <DateTime>[];
    var cursor = start;
    while (!cursor.isAfter(end)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }

    final map = <DateTime, _DailyPoint>{
      for (final d in days) d: _DailyPoint(date: d, collections: 0, expenses: 0),
    };

    for (final t in sorted) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      final p = map[d];
      if (p == null) continue;
      if (t.type == PujaTransactionType.collection) {
        map[d] = p.copyWith(collections: p.collections + t.amount);
      } else {
        map[d] = p.copyWith(expenses: p.expenses + t.amount);
      }
    }

    return map.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initial = _range ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initial,
    );

    if (picked == null) return;
    setState(() => _range = picked);
  }
}

class _DailyPoint {
  final DateTime date;
  final double collections;
  final double expenses;

  const _DailyPoint({
    required this.date,
    required this.collections,
    required this.expenses,
  });

  _DailyPoint copyWith({
    double? collections,
    double? expenses,
  }) {
    return _DailyPoint(
      date: date,
      collections: collections ?? this.collections,
      expenses: expenses ?? this.expenses,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textGrey)),
      ],
    );
  }
}
