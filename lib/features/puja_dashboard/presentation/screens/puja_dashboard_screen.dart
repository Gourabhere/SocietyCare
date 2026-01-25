import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/puja_strings.dart';
import '../providers/dashboard_provider.dart';
import '../providers/puja_permissions_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_chart.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stats_card.dart';
import '../widgets/transaction_card.dart';
import 'ai_screenshot_upload_screen.dart';
import 'analytics_screen.dart';
import 'export_screen.dart';
import 'transaction_detail_screen.dart';
import 'transaction_list_screen.dart';
import 'user_management_screen.dart';

class PujaDashboardScreen extends ConsumerWidget {
  const PujaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(pujaIsAdminProvider);
    final transactionsAsync = ref.watch(pujaTransactionsProvider);
    final statsAsync = ref.watch(pujaDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(PujaStrings.dashboardTitle),
        actions: [
          IconButton(
            tooltip: PujaStrings.aiScan,
            icon: const Icon(Icons.document_scanner),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiScreenshotUploadScreen()),
              );
            },
          ),
          if (isAdmin)
            IconButton(
              tooltip: PujaStrings.users,
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                );
              },
            ),
          IconButton(
            tooltip: PujaStrings.export,
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExportScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(pujaTransactionsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              PujaStrings.moduleTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            statsAsync.when(
              data: (stats) {
                final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
                return LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth >= 900;
                    final statCards = [
                      StatsCard(
                        title: PujaStrings.collectionsLabel,
                        value: currency.format(stats.totalCollections),
                        icon: Icons.call_received,
                        color: AppColors.successGreen,
                      ),
                      StatsCard(
                        title: PujaStrings.expensesLabel,
                        value: currency.format(stats.totalExpenses),
                        icon: Icons.call_made,
                        color: AppColors.errorRed,
                      ),
                      StatsCard(
                        title: PujaStrings.balanceLabel,
                        value: currency.format(stats.balance),
                        icon: Icons.account_balance_wallet,
                        color: AppColors.primaryBlue,
                      ),
                    ];

                    if (wide) {
                      return Row(
                        children: [
                          for (final card in statCards)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: card,
                              ),
                            ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        for (final card in statCards) ...[
                          card,
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Failed to load stats: $e',
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) {
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category Breakdown',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          PujaStrings.collections,
                          style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600),
                        ),
                        CategoryChart(data: stats.collectionsByCategory, isCollection: true),
                        const Divider(height: 32),
                        const Text(
                          PujaStrings.expenses,
                          style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600),
                        ),
                        CategoryChart(data: stats.expensesByCategory, isCollection: false),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View All Transactions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text(PujaStrings.analytics),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              PujaStrings.recentTransactions,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const EmptyStateWidget(
                    title: PujaStrings.noTransactions,
                    subtitle: 'Use AI scan or ask an admin to add entries.',
                    icon: Icons.receipt_long,
                  );
                }
                final recent = transactions.take(10).toList();
                return Column(
                  children: [
                    for (final t in recent)
                      TransactionCard(
                        transaction: t,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TransactionListScreen(initialTransactionId: t.id),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Failed to load transactions: $e',
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TransactionListScreen(openAdd: true),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(PujaStrings.addTransaction),
            )
          : null,
    );
  }
}
