import 'package:uuid/uuid.dart';

import '../../../../utils/date_formatter_utils.dart';
import '../../domain/entities/transaction.dart';

class PujaTransactionModel {
  final String id;
  final PujaTransactionType type;
  final String category;
  final double amount;
  final String? description;
  final String donorPayerName;
  final DateTime date;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PujaTransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.donorPayerName,
    required this.date,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory PujaTransactionModel.newDraft({
    required PujaTransactionType type,
    required String category,
    required double amount,
    required String donorPayerName,
    required DateTime date,
    required String createdBy,
    String? description,
  }) {
    final now = DateTime.now().toUtc();
    return PujaTransactionModel(
      id: const Uuid().v4(),
      type: type,
      category: category,
      amount: amount,
      donorPayerName: donorPayerName,
      date: DateTime(date.year, date.month, date.day),
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
      description: description,
    );
  }

  factory PujaTransactionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String?) ?? 'collection';
    final amountRaw = json['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw?.toString() ?? '0') ?? 0;

    return PujaTransactionModel(
      id: json['id'] as String,
      type: typeStr == 'expense'
          ? PujaTransactionType.expense
          : PujaTransactionType.collection,
      category: (json['category'] as String?) ?? '',
      amount: amount,
      description: json['description'] as String?,
      donorPayerName: (json['donor_payer_name'] as String?) ?? '',
      date: DateFormatterUtils.parseSupabaseDate(json['date']),
      createdBy: (json['created_by'] as String?) ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id': id,
      'type': type.name,
      'category': category,
      'amount': amount,
      'description': description,
      'donor_payer_name': donorPayerName,
      'date': DateFormatterUtils.formatIsoDate(date),
      'created_by': createdBy,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'type': type.name,
      'category': category,
      'amount': amount,
      'description': description,
      'donor_payer_name': donorPayerName,
      'date': DateFormatterUtils.formatIsoDate(date),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  PujaTransaction toEntity() {
    return PujaTransaction(
      id: id,
      type: type,
      category: category,
      amount: amount,
      donorPayerName: donorPayerName,
      date: date,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
    );
  }

  static PujaTransactionModel fromEntity(PujaTransaction entity) {
    return PujaTransactionModel(
      id: entity.id,
      type: entity.type,
      category: entity.category,
      amount: entity.amount,
      description: entity.description,
      donorPayerName: entity.donorPayerName,
      date: entity.date,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
