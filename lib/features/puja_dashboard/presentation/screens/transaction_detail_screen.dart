import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../constants/app_colors.dart';
import '../../../../utils/date_formatter_utils.dart';
import '../../domain/entities/transaction.dart';
import '../providers/attachment_provider.dart';
import '../providers/puja_dependencies.dart';
import '../providers/puja_permissions_provider.dart';
import '../widgets/attachment_image_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final PujaTransaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(pujaIsAdminProvider);
    final attachmentsAsync = ref.watch(pujaAttachmentsProvider(transaction.id));

    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final amountColor = transaction.type == PujaTransactionType.collection
        ? AppColors.successGreen
        : AppColors.errorRed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final msg = [
                'Type: ${transaction.type.name}',
                'Category: ${transaction.category}',
                'Amount: ${currency.format(transaction.amount)}',
                'Name: ${transaction.donorPayerName}',
                'Date: ${DateFormatterUtils.formatUi(transaction.date)}',
                if (transaction.description != null && transaction.description!.trim().isNotEmpty)
                  'Notes: ${transaction.description}',
              ].join('\n');
              Share.share(msg);
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.of(context).push<PujaTransaction?>(
                  MaterialPageRoute(
                    builder: (_) => EditTransactionScreen(transaction: transaction),
                  ),
                );
                if (updated != null) {
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.format(transaction.amount),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    transaction.donorPayerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(label: transaction.type.name.toUpperCase()),
                      _Chip(label: transaction.category),
                      _Chip(label: DateFormatterUtils.formatUi(transaction.date)),
                    ],
                  ),
                  if (transaction.description != null && transaction.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      transaction.description!,
                      style: const TextStyle(color: AppColors.textDark),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Attachments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          attachmentsAsync.when(
            data: (attachments) {
              if (attachments.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No attachments',
                  subtitle: 'Admins can add screenshots while editing the transaction.',
                  icon: Icons.photo_library_outlined,
                );
              }

              return SizedBox(
                height: 128,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final a = attachments[index];
                    final url = ref.watch(pujaAttachmentUrlProvider(a.filePath));
                    return AttachmentImageWidget(
                      imageUrl: url,
                      onTap: () => _openImage(context, url),
                      onDelete: isAdmin
                          ? () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete attachment?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.errorRed,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok != true) return;

                              try {
                                final repo = ref.read(pujaRepositoryProvider);
                                await repo.deleteAttachment(
                                  attachmentId: a.id,
                                  filePath: a.filePath,
                                );
                              } catch (e) {
                                Fluttertoast.showToast(msg: 'Failed: $e');
                              }
                            }
                          : null,
                    );
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              'Failed to load attachments: $e',
              style: const TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _openImage(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
