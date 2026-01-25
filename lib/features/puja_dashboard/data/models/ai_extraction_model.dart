import '../../domain/entities/ai_extraction.dart';
import '../../domain/entities/transaction.dart';

enum AiProcessingStatus { pending, confirmed, rejected }

class AiProcessingLogModel {
  final String id;
  final String userId;
  final AiExtractionResult extractedData;
  final AiProcessingStatus status;
  final DateTime createdAt;

  const AiProcessingLogModel({
    required this.id,
    required this.userId,
    required this.extractedData,
    required this.status,
    required this.createdAt,
  });

  factory AiProcessingLogModel.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String?) ?? 'pending';
    final extracted = (json['extracted_data'] as Map<String, dynamic>?) ?? const {};

    return AiProcessingLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      extractedData: AiExtractionResult(
        transactionType: _parseType(extracted['transactionType'] as String?),
        amount: (extracted['amount'] as num?)?.toDouble(),
        amountConfidence: (extracted['amountConfidence'] as num?)?.toDouble() ?? 0,
        donorPayerName: extracted['donorPayerName'] as String?,
        nameConfidence: (extracted['nameConfidence'] as num?)?.toDouble() ?? 0,
        date: extracted['date'] is String ? DateTime.tryParse(extracted['date'] as String) : null,
        dateConfidence: (extracted['dateConfidence'] as num?)?.toDouble() ?? 0,
        category: extracted['category'] as String?,
        categoryConfidence: (extracted['categoryConfidence'] as num?)?.toDouble() ?? 0,
        rawText: extracted['rawText'] as String? ?? '',
      ),
      status: AiProcessingStatus.values.firstWhere(
        (v) => v.name == statusStr,
        orElse: () => AiProcessingStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'extracted_data': extractedData.toJson(),
      'status': status.name,
    };
  }

  static PujaTransactionType _parseType(String? value) {
    return value == PujaTransactionType.expense.name
        ? PujaTransactionType.expense
        : PujaTransactionType.collection;
  }
}
