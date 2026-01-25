import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/puja_local_datasource.dart';
import '../datasources/puja_remote_datasource.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/puja_repository.dart';

class PujaRepositoryImpl implements PujaRepository {
  final SupabaseClient _client;
  final PujaRemoteDatasource _remote;
  final PujaLocalDatasource _local;

  PujaRepositoryImpl({
    required SupabaseClient client,
    required PujaRemoteDatasource remote,
    required PujaLocalDatasource local,
  })  : _client = client,
        _remote = remote,
        _local = local;

  @override
  Stream<List<PujaTransaction>> watchTransactions() async* {
    await for (final models in _remote.watchTransactions()) {
      unawaited(_local.cacheTransactions(models));
      yield models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<List<PujaTransaction>> getCachedTransactions() async {
    final models = await _local.getCachedTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }
    return userId;
  }

  @override
  Future<PujaTransaction> createTransaction({
    required PujaTransactionType type,
    required String category,
    required double amount,
    required String donorPayerName,
    required DateTime date,
    String? description,
  }) async {
    final userId = _requireUserId();
    final draft = PujaTransactionModel.newDraft(
      type: type,
      category: category,
      amount: amount,
      donorPayerName: donorPayerName,
      date: date,
      createdBy: userId,
      description: description,
    );

    final created = await _remote.createTransaction(draft);
    await _remote.logAdminAction(
      userId: userId,
      action: 'Created puja transaction',
      metadata: {'transactionId': created.id, 'type': created.type.name},
    );

    return created.toEntity();
  }

  @override
  Future<PujaTransaction> updateTransaction(PujaTransaction transaction) async {
    final userId = _requireUserId();
    final model = PujaTransactionModel.fromEntity(transaction);
    final updated = await _remote.updateTransaction(model);
    await _remote.logAdminAction(
      userId: userId,
      action: 'Updated puja transaction',
      metadata: {'transactionId': updated.id},
    );
    return updated.toEntity();
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final userId = _requireUserId();
    await _remote.deleteTransaction(transactionId);
    await _remote.logAdminAction(
      userId: userId,
      action: 'Deleted puja transaction',
      metadata: {'transactionId': transactionId},
    );
  }

  @override
  Stream<List<PujaAttachment>> watchAttachments(String transactionId) {
    return _remote
        .watchAttachments(transactionId)
        .map((rows) => rows.map((m) => m.toEntity()).toList());
  }

  @override
  Future<PujaAttachment> uploadAttachment({
    required String transactionId,
    required String filename,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final userId = _requireUserId();
    final model = await _remote.uploadAttachment(
      transactionId: transactionId,
      filename: filename,
      bytes: bytes,
      mimeType: mimeType,
    );

    await _remote.logAdminAction(
      userId: userId,
      action: 'Uploaded puja attachment',
      metadata: {'transactionId': transactionId, 'attachmentId': model.id},
    );

    return model.toEntity();
  }

  @override
  Future<void> deleteAttachment({
    required String attachmentId,
    required String filePath,
  }) async {
    final userId = _requireUserId();
    await _remote.deleteAttachment(attachmentId: attachmentId, filePath: filePath);
    await _remote.logAdminAction(
      userId: userId,
      action: 'Deleted puja attachment',
      metadata: {'attachmentId': attachmentId},
    );
  }

  @override
  Future<PujaDashboardStats> computeStats(List<PujaTransaction> transactions) async {
    double collections = 0;
    double expenses = 0;
    final collectionsByCategory = <String, double>{};
    final expensesByCategory = <String, double>{};

    for (final t in transactions) {
      if (t.type == PujaTransactionType.collection) {
        collections += t.amount;
        collectionsByCategory[t.category] = (collectionsByCategory[t.category] ?? 0) + t.amount;
      } else {
        expenses += t.amount;
        expensesByCategory[t.category] = (expensesByCategory[t.category] ?? 0) + t.amount;
      }
    }

    return PujaDashboardStats(
      totalCollections: collections,
      totalExpenses: expenses,
      balance: collections - expenses,
      collectionsByCategory: collectionsByCategory,
      expensesByCategory: expensesByCategory,
    );
  }
}
