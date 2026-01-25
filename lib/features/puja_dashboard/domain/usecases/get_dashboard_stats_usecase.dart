import '../entities/dashboard_stats.dart';
import '../entities/transaction.dart';
import '../repositories/puja_repository.dart';

class GetDashboardStatsUsecase {
  final PujaRepository _repo;

  const GetDashboardStatsUsecase(this._repo);

  Future<PujaDashboardStats> call(List<PujaTransaction> transactions) {
    return _repo.computeStats(transactions);
  }
}
