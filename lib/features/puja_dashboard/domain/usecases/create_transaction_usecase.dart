import '../entities/transaction.dart';
import '../repositories/puja_repository.dart';

class CreateTransactionUsecase {
  final PujaRepository _repo;

  const CreateTransactionUsecase(this._repo);

  Future<PujaTransaction> call({
    required PujaTransactionType type,
    required String category,
    required double amount,
    required String donorPayerName,
    required DateTime date,
    String? description,
  }) {
    return _repo.createTransaction(
      type: type,
      category: category,
      amount: amount,
      donorPayerName: donorPayerName,
      date: date,
      description: description,
    );
  }
}
