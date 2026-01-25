import 'transaction.dart';

class AiExtractionResult {
  final PujaTransactionType transactionType;
  final double? amount;
  final double amountConfidence;
  final String? donorPayerName;
  final double nameConfidence;
  final DateTime? date;
  final double dateConfidence;
  final String? category;
  final double categoryConfidence;
  final String rawText;

  const AiExtractionResult({
    required this.transactionType,
    required this.amount,
    required this.amountConfidence,
    required this.donorPayerName,
    required this.nameConfidence,
    required this.date,
    required this.dateConfidence,
    required this.category,
    required this.categoryConfidence,
    required this.rawText,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionType': transactionType.name,
      'amount': amount,
      'amountConfidence': amountConfidence,
      'donorPayerName': donorPayerName,
      'nameConfidence': nameConfidence,
      'date': date?.toIso8601String(),
      'dateConfidence': dateConfidence,
      'category': category,
      'categoryConfidence': categoryConfidence,
      'rawText': rawText,
    };
  }
}
