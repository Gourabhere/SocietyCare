import '../features/puja_dashboard/domain/entities/transaction.dart';

class PujaCategories {
  static const List<String> collectionCategories = [
    'Individual Donations',
    'Corporate Sponsorships',
    'Pledges',
    'Other',
  ];

  static const List<String> expenseCategories = [
    'Decorations',
    'Prasad/Food',
    'Staff Payments',
    'Logistics',
    'Equipment Rental',
    'Miscellaneous',
  ];

  static List<String> forType(PujaTransactionType type) {
    return type == PujaTransactionType.collection
        ? collectionCategories
        : expenseCategories;
  }
}
