import '../entities/attachment.dart';
import '../entities/dashboard_stats.dart';
import '../entities/transaction.dart';

abstract class PujaRepository {
  Stream<List<PujaTransaction>> watchTransactions();
  Future<List<PujaTransaction>> getCachedTransactions();

  Future<PujaTransaction> createTransaction({
    required PujaTransactionType type,
    required String category,
    required double amount,
    required String donorPayerName,
    required DateTime date,
    String? description,
  });

  Future<PujaTransaction> updateTransaction(PujaTransaction transaction);

  Future<void> deleteTransaction(String transactionId);

  Stream<List<PujaAttachment>> watchAttachments(String transactionId);

  Future<PujaAttachment> uploadAttachment({
    required String transactionId,
    required String filename,
    required List<int> bytes,
    required String mimeType,
  });

  Future<void> deleteAttachment({
    required String attachmentId,
    required String filePath,
  });

  Future<PujaDashboardStats> computeStats(List<PujaTransaction> transactions);
}
