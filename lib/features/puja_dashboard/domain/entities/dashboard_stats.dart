class PujaDashboardStats {
  final double totalCollections;
  final double totalExpenses;
  final double balance;
  final Map<String, double> collectionsByCategory;
  final Map<String, double> expensesByCategory;

  const PujaDashboardStats({
    required this.totalCollections,
    required this.totalExpenses,
    required this.balance,
    required this.collectionsByCategory,
    required this.expensesByCategory,
  });
}
