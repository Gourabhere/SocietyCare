import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transaction.dart';
import 'puja_dependencies.dart';

const int pujaPageSize = 20;

class PujaTransactionFilters {
  final PujaTransactionType? type;
  final String? category;
  final DateTimeRange? dateRange;
  final String searchQuery;
  final bool sortByAmountDesc;

  const PujaTransactionFilters({
    this.type,
    this.category,
    this.dateRange,
    this.searchQuery = '',
    this.sortByAmountDesc = false,
  });

  PujaTransactionFilters copyWith({
    PujaTransactionType? type,
    String? category,
    DateTimeRange? dateRange,
    String? searchQuery,
    bool? sortByAmountDesc,
    bool clearType = false,
    bool clearCategory = false,
    bool clearDateRange = false,
  }) {
    return PujaTransactionFilters(
      type: clearType ? null : (type ?? this.type),
      category: clearCategory ? null : (category ?? this.category),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      searchQuery: searchQuery ?? this.searchQuery,
      sortByAmountDesc: sortByAmountDesc ?? this.sortByAmountDesc,
    );
  }
}

final pujaTransactionFiltersProvider = StateProvider<PujaTransactionFilters>((ref) {
  return const PujaTransactionFilters();
});

final pujaPageIndexProvider = StateProvider<int>((ref) => 0);

final pujaTransactionsProvider = AutoDisposeAsyncNotifierProvider<PujaTransactionsController, List<PujaTransaction>>(
  PujaTransactionsController.new,
);

class PujaTransactionsController extends AutoDisposeAsyncNotifier<List<PujaTransaction>> {
  StreamSubscription<List<PujaTransaction>>? _sub;

  @override
  Future<List<PujaTransaction>> build() async {
    final repo = ref.watch(pujaRepositoryProvider);

    final cached = await repo.getCachedTransactions();

    _sub = repo.watchTransactions().listen(
      (data) {
        state = AsyncValue.data(data);
      },
      onError: (error, stack) {
        if (state.hasError || state.isLoading) {
          state = AsyncValue.data(cached);
        }
      },
    );

    ref.onDispose(() {
      _sub?.cancel();
    });

    return cached;
  }

  Future<void> refresh() async {
    final repo = ref.read(pujaRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final cached = await repo.getCachedTransactions();
      state = AsyncValue.data(cached);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final pujaFilteredTransactionsProvider = Provider<List<PujaTransaction>>((ref) {
  final transactionsAsync = ref.watch(pujaTransactionsProvider);
  final filters = ref.watch(pujaTransactionFiltersProvider);

  final transactions = transactionsAsync.maybeWhen(data: (d) => d, orElse: () => const <PujaTransaction>[]);

  Iterable<PujaTransaction> filtered = transactions;

  if (filters.type != null) {
    filtered = filtered.where((t) => t.type == filters.type);
  }

  if (filters.category != null && filters.category!.isNotEmpty) {
    filtered = filtered.where((t) => t.category == filters.category);
  }

  if (filters.dateRange != null) {
    final start = DateTime(filters.dateRange!.start.year, filters.dateRange!.start.month, filters.dateRange!.start.day);
    final end = DateTime(filters.dateRange!.end.year, filters.dateRange!.end.month, filters.dateRange!.end.day);
    filtered = filtered.where((t) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      return (d.isAtSameMomentAs(start) || d.isAfter(start)) &&
          (d.isAtSameMomentAs(end) || d.isBefore(end));
    });
  }

  final q = filters.searchQuery.trim().toLowerCase();
  if (q.isNotEmpty) {
    filtered = filtered.where((t) => t.donorPayerName.toLowerCase().contains(q));
  }

  final list = filtered.toList();
  if (filters.sortByAmountDesc) {
    list.sort((a, b) => b.amount.compareTo(a.amount));
  } else {
    list.sort((a, b) => b.date.compareTo(a.date));
  }

  return list;
});

final pujaPaginatedTransactionsProvider = Provider<List<PujaTransaction>>((ref) {
  final list = ref.watch(pujaFilteredTransactionsProvider);
  final page = ref.watch(pujaPageIndexProvider);

  final start = page * pujaPageSize;
  if (start >= list.length) return [];
  final end = (start + pujaPageSize).clamp(0, list.length);
  return list.sublist(start, end);
});

final pujaTotalPagesProvider = Provider<int>((ref) {
  final list = ref.watch(pujaFilteredTransactionsProvider);
  if (list.isEmpty) return 1;
  return ((list.length - 1) / pujaPageSize).floor() + 1;
});
