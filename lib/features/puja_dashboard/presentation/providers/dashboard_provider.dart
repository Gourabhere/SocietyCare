import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_stats.dart';
import 'puja_dependencies.dart';
import 'transaction_provider.dart';

final pujaDashboardStatsProvider = FutureProvider.autoDispose<PujaDashboardStats>((ref) async {
  final keepAliveLink = ref.keepAlive();
  Timer(const Duration(seconds: 30), keepAliveLink.close);

  final repo = ref.watch(pujaRepositoryProvider);
  final transactions = ref.watch(pujaTransactionsProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const [],
      );

  return repo.computeStats(transactions);
});
