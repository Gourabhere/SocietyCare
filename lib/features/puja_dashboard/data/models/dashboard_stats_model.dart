import '../../domain/entities/dashboard_stats.dart';

class PujaDashboardStatsModel {
  final double totalCollections;
  final double totalExpenses;
  final Map<String, double> collectionsByCategory;
  final Map<String, double> expensesByCategory;

  const PujaDashboardStatsModel({
    required this.totalCollections,
    required this.totalExpenses,
    required this.collectionsByCategory,
    required this.expensesByCategory,
  });

  PujaDashboardStats toEntity() {
    return PujaDashboardStats(
      totalCollections: totalCollections,
      totalExpenses: totalExpenses,
      balance: totalCollections - totalExpenses,
      collectionsByCategory: collectionsByCategory,
      expensesByCategory: expensesByCategory,
    );
  }
}
