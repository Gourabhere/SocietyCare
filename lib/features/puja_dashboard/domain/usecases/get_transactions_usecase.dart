import '../entities/transaction.dart';
import '../repositories/puja_repository.dart';

class GetTransactionsUsecase {
  final PujaRepository _repo;

  const GetTransactionsUsecase(this._repo);

  Stream<List<PujaTransaction>> watch() => _repo.watchTransactions();
}
