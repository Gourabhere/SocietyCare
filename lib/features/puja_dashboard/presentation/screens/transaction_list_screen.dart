import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/puja_categories.dart';
import '../../../../constants/puja_strings.dart';
import '../../domain/entities/transaction.dart';
import '../providers/puja_permissions_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  final String? initialTransactionId;
  final bool openAdd;

  const TransactionListScreen({
    super.key,
    this.initialTransactionId,
    this.openAdd = false,
  });

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.openAdd && ref.read(pujaIsAdminProvider)) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        );
      }

      if (widget.initialTransactionId != null) {
        final tx = ref
            .read(pujaFilteredTransactionsProvider)
            .where((t) => t.id == widget.initialTransactionId)
            .toList();
        if (tx.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TransactionDetailScreen(transaction: tx.first)),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(pujaIsAdminProvider);
    final filters = ref.watch(pujaTransactionFiltersProvider);
    final transactionsAsync = ref.watch(pujaTransactionsProvider);
    final paginated = ref.watch(pujaPaginatedTransactionsProvider);
    final page = ref.watch(pujaPageIndexProvider);
    final totalPages = ref.watch(pujaTotalPagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _openFilterSheet(filters),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by donor/payer name',
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                ref.read(pujaPageIndexProvider.notifier).state = 0;
                ref.read(pujaTransactionFiltersProvider.notifier).state =
                    filters.copyWith(searchQuery: v);
              },
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              data: (_) {
                if (paginated.isEmpty) {
                  return const EmptyStateWidget(
                    title: PujaStrings.noTransactions,
                    subtitle: 'Try changing filters or date range.',
                    icon: Icons.receipt_long,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: paginated.length + 1,
                  itemBuilder: (context, index) {
                    if (index == paginated.length) {
                      return _PaginationFooter(
                        page: page,
                        totalPages: totalPages,
                        onPrev: page > 0
                            ? () => ref.read(pujaPageIndexProvider.notifier).state = page - 1
                            : null,
                        onNext: page < totalPages - 1
                            ? () => ref.read(pujaPageIndexProvider.notifier).state = page + 1
                            : null,
                      );
                    }

                    final t = paginated[index];
                    return TransactionCard(
                      transaction: t,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TransactionDetailScreen(transaction: t)),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load transactions: $e',
                    style: const TextStyle(color: AppColors.errorRed),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _openFilterSheet(PujaTransactionFilters filters) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        PujaTransactionType? selectedType = filters.type;
        String? selectedCategory = filters.category;
        bool sortByAmount = filters.sortByAmountDesc;

        final categories = selectedType == null
            ? <String>[]
            : PujaCategories.forType(selectedType);

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PujaTransactionType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: PujaStrings.type),
                    items: const [
                      DropdownMenuItem(
                        value: PujaTransactionType.collection,
                        child: Text('Collection'),
                      ),
                      DropdownMenuItem(
                        value: PujaTransactionType.expense,
                        child: Text('Expense'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedType = v;
                        selectedCategory = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: PujaStrings.category),
                    items: [
                      for (final c in categories)
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: selectedType == null
                        ? null
                        : (v) {
                            setState(() {
                              selectedCategory = v;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sort by amount (desc)'),
                    value: sortByAmount,
                    onChanged: (v) => setState(() => sortByAmount = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(pujaPageIndexProvider.notifier).state = 0;
                            ref.read(pujaTransactionFiltersProvider.notifier).state =
                                filters.copyWith(
                              clearType: true,
                              clearCategory: true,
                              clearDateRange: true,
                              searchQuery: '',
                              sortByAmountDesc: false,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(pujaPageIndexProvider.notifier).state = 0;
                            ref.read(pujaTransactionFiltersProvider.notifier).state =
                                filters.copyWith(
                              type: selectedType,
                              category: selectedCategory,
                              sortByAmountDesc: sortByAmount,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationFooter({
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Text('Page ${page + 1} of $totalPages'),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}
