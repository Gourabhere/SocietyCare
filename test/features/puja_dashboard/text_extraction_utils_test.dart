import 'package:flutter_test/flutter_test.dart';

import 'package:facility_keeper/utils/text_extraction_utils.dart';
import 'package:facility_keeper/features/puja_dashboard/domain/entities/transaction.dart';

void main() {
  group('TextExtractionUtils.parseWhatsAppText', () {
    test('extracts amount with rupee symbol', () {
      final res = TextExtractionUtils.parseWhatsAppText('Received ₹1,250 from Amit on 12/01/2026');
      expect(res.amount, 1250);
      expect(res.amountConfidence, greaterThan(0.5));
    });

    test('infers expense type from keywords', () {
      final res = TextExtractionUtils.parseWhatsAppText('Paid Rs. 500 for decorations 12-01-2026');
      expect(res.transactionType, PujaTransactionType.expense);
    });

    test('extracts date', () {
      final res = TextExtractionUtils.parseWhatsAppText('Donation ₹2000\nDate: 05/02/2026');
      expect(res.date, isNotNull);
      expect(res.date!.year, 2026);
      expect(res.date!.month, 2);
      expect(res.date!.day, 5);
    });
  });
}
