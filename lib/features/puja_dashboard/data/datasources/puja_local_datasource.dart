import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/transaction_model.dart';

class PujaLocalDatasource {
  static const String _boxName = 'puja_transactions_cache';
  static const String _transactionsKey = 'transactions_json';
  static const String _cachedAtKey = 'cached_at';

  Future<Box<String>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  Future<void> cacheTransactions(List<PujaTransactionModel> transactions) async {
    final box = await _openBox();
    final jsonList = transactions.map((t) => t.toInsertJson()..addAll({'created_at': t.createdAt.toIso8601String(), 'updated_at': t.updatedAt.toIso8601String()})).toList();
    await box.put(_transactionsKey, jsonEncode(jsonList));
    await box.put(_cachedAtKey, DateTime.now().toUtc().toIso8601String());
  }

  Future<List<PujaTransactionModel>> getCachedTransactions() async {
    final box = await _openBox();
    final jsonStr = box.get(_transactionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final parsed = jsonDecode(jsonStr);
    if (parsed is! List) return [];

    final list = <PujaTransactionModel>[];
    for (final item in parsed) {
      if (item is Map<String, dynamic>) {
        final map = Map<String, dynamic>.from(item);
        map['created_by'] = map['created_by'] ?? '';
        map['created_at'] = map['created_at'] ?? DateTime.now().toUtc().toIso8601String();
        map['updated_at'] = map['updated_at'] ?? DateTime.now().toUtc().toIso8601String();
        list.add(PujaTransactionModel.fromJson(map));
      } else if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        map['created_by'] = map['created_by'] ?? '';
        map['created_at'] = map['created_at'] ?? DateTime.now().toUtc().toIso8601String();
        map['updated_at'] = map['updated_at'] ?? DateTime.now().toUtc().toIso8601String();
        list.add(PujaTransactionModel.fromJson(map));
      }
    }

    return list;
  }

  Future<DateTime?> getCachedAt() async {
    final box = await _openBox();
    final cachedAtStr = box.get(_cachedAtKey);
    if (cachedAtStr == null) return null;
    return DateTime.tryParse(cachedAtStr);
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
