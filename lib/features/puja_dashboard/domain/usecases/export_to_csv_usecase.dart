import 'package:csv/csv.dart';

import '../entities/transaction.dart';

class ExportToCsvUsecase {
  const ExportToCsvUsecase();

  String call(List<PujaTransaction> transactions) {
    final rows = <List<dynamic>>[
      ['Type', 'Category', 'Amount', 'Name', 'Date', 'Description'],
      ...transactions.map(
        (t) => [
          t.type.name,
          t.category,
          t.amount.toStringAsFixed(2),
          t.donorPayerName,
          t.date.toIso8601String().split('T').first,
          t.description ?? '',
        ],
      ),
    ];
    return const ListToCsvConverter().convert(rows);
  }
}
