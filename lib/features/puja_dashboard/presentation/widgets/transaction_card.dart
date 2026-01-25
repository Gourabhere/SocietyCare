import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../../../../utils/date_formatter_utils.dart';

class TransactionCard extends StatelessWidget {
  final PujaTransaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCollection = transaction.type == PujaTransactionType.collection;
    final color = isCollection ? AppColors.successGreen : AppColors.errorRed;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(isCollection ? Icons.call_received : Icons.call_made, color: color),
        ),
        title: Text(
          transaction.donorPayerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${transaction.category} • ${DateFormatterUtils.formatUi(transaction.date)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Text(
          NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(transaction.amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
