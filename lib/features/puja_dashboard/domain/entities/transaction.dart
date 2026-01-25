enum PujaTransactionType { collection, expense }

class PujaTransaction {
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

  const PujaTransaction({
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

  PujaTransaction copyWith({
    String? id,
    PujaTransactionType? type,
    String? category,
    double? amount,
    String? description,
    String? donorPayerName,
    DateTime? date,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PujaTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      donorPayerName: donorPayerName ?? this.donorPayerName,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
