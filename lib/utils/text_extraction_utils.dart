import 'package:intl/intl.dart';

import '../features/puja_dashboard/domain/entities/transaction.dart';
import '../features/puja_dashboard/domain/entities/ai_extraction.dart';

class TextExtractionUtils {
  static AiExtractionResult parseWhatsAppText(String rawText) {
    final text = rawText.replaceAll('\u00A0', ' ').trim();

    final amountMatch = _findAmount(text);
    final dateMatch = _findDate(text);
    final type = _inferType(text);
    final nameMatch = _findName(text);
    final category = _inferCategory(text, type);

    return AiExtractionResult(
      transactionType: type,
      amount: amountMatch?.value,
      amountConfidence: amountMatch?.confidence ?? 0.0,
      donorPayerName: nameMatch?.value,
      nameConfidence: nameMatch?.confidence ?? 0.0,
      date: dateMatch?.value,
      dateConfidence: dateMatch?.confidence ?? 0.0,
      category: category?.value,
      categoryConfidence: category?.confidence ?? 0.0,
      rawText: rawText,
    );
  }

  static _Extracted<double>? _findAmount(String text) {
    final patterns = [
      RegExp(r'(₹|rs\.?|inr)\s*([0-9][0-9,]*\.?[0-9]{0,2})', caseSensitive: false),
      RegExp(r'\b([0-9][0-9,]*\.?[0-9]{0,2})\s*(₹|rs\.?|inr)\b', caseSensitive: false),
      RegExp(r'\bamount\s*[:=-]?\s*([0-9][0-9,]*\.?[0-9]{0,2})\b', caseSensitive: false),
    ];

    for (final p in patterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        final numStr = (m.groupCount >= 2 ? m.group(2) : m.group(1)) ?? '';
        final normalized = numStr.replaceAll(',', '');
        final value = double.tryParse(normalized);
        if (value != null && value > 0) {
          return _Extracted(value: value, confidence: 0.9);
        }
      }
    }

    final fallback = RegExp(r'\b([0-9]{2,6}(?:\.[0-9]{1,2})?)\b').allMatches(text).toList();
    if (fallback.isNotEmpty) {
      final best = fallback.map((m) => m.group(1)!).first;
      final value = double.tryParse(best);
      if (value != null && value > 0) {
        return _Extracted(value: value, confidence: 0.4);
      }
    }

    return null;
  }

  static _Extracted<DateTime>? _findDate(String text) {
    final dateLike = <String>[];
    final numeric = RegExp(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})\b').allMatches(text);
    for (final m in numeric) {
      dateLike.add(m.group(0)!);
    }

    final months = RegExp(
      r'\b(\d{1,2})\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)[a-z]*\s*(\d{2,4})?\b',
      caseSensitive: false,
    ).allMatches(text);
    for (final m in months) {
      dateLike.add(m.group(0)!);
    }

    for (final candidate in dateLike) {
      final parsed = _tryParseDate(candidate);
      if (parsed != null) {
        return _Extracted(value: parsed, confidence: 0.85);
      }
    }

    return null;
  }

  static DateTime? _tryParseDate(String input) {
    final formats = [
      DateFormat('d/M/yyyy'),
      DateFormat('d/M/yy'),
      DateFormat('d-M-yyyy'),
      DateFormat('d-M-yy'),
      DateFormat('d MMM yyyy'),
      DateFormat('d MMM yy'),
      DateFormat('d MMM'),
    ];

    for (final f in formats) {
      try {
        final dt = f.parseStrict(input);
        if (f.pattern == 'd MMM' && dt.year == 1970) {
          final now = DateTime.now();
          return DateTime(now.year, dt.month, dt.day);
        }
        if (dt.year < 100) {
          final year = 2000 + dt.year;
          return DateTime(year, dt.month, dt.day);
        }
        return DateTime(dt.year, dt.month, dt.day);
      } catch (_) {}
    }
    return null;
  }

  static PujaTransactionType _inferType(String text) {
    final lower = text.toLowerCase();
    final collectionWords = [
      'received',
      'donation',
      'donated',
      'credited',
      'collected',
      'sponsorship',
      'pledge',
    ];
    final expenseWords = ['paid', 'spent', 'debit', 'purchased', 'payment'];

    final hasCollection = collectionWords.any(lower.contains);
    final hasExpense = expenseWords.any(lower.contains);

    if (hasCollection && !hasExpense) return PujaTransactionType.collection;
    if (hasExpense && !hasCollection) return PujaTransactionType.expense;

    return PujaTransactionType.collection;
  }

  static _Extracted<String>? _findName(String text) {
    final fromBy = RegExp(r'\b(from|by)\s+([A-Za-z][A-Za-z .]{1,50})', caseSensitive: false);
    final m = fromBy.firstMatch(text);
    if (m != null) {
      final val = m.group(2)!.trim();
      if (val.isNotEmpty) return _Extracted(value: _cleanupName(val), confidence: 0.8);
    }

    final lines = text
        .split(RegExp(r'[\n\r]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    for (final line in lines.take(6)) {
      if (RegExp(r'\d').hasMatch(line)) continue;
      if (line.length < 3 || line.length > 50) continue;
      if (RegExp(r'^(hi|hello|thanks|thank you)\b', caseSensitive: false).hasMatch(line)) {
        continue;
      }
      if (RegExp(r'^[A-Za-z][A-Za-z ]+$').hasMatch(line)) {
        return _Extracted(value: _cleanupName(line), confidence: 0.55);
      }
    }

    return null;
  }

  static String _cleanupName(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^A-Za-z .]'), '')
        .trim();
  }

  static _Extracted<String>? _inferCategory(String text, PujaTransactionType type) {
    final lower = text.toLowerCase();
    if (type == PujaTransactionType.collection) {
      if (lower.contains('sponsor')) return _Extracted(value: 'Corporate Sponsorships', confidence: 0.75);
      if (lower.contains('pledge')) return _Extracted(value: 'Pledges', confidence: 0.75);
      if (lower.contains('donat')) return _Extracted(value: 'Individual Donations', confidence: 0.6);
      return _Extracted(value: 'Other', confidence: 0.35);
    }

    if (lower.contains('decor')) return _Extracted(value: 'Decorations', confidence: 0.75);
    if (lower.contains('prasad') || lower.contains('food')) {
      return _Extracted(value: 'Prasad/Food', confidence: 0.75);
    }
    if (lower.contains('staff')) return _Extracted(value: 'Staff Payments', confidence: 0.7);
    if (lower.contains('logistic') || lower.contains('transport')) {
      return _Extracted(value: 'Logistics', confidence: 0.7);
    }
    if (lower.contains('rent') || lower.contains('rental')) {
      return _Extracted(value: 'Equipment Rental', confidence: 0.7);
    }

    return _Extracted(value: 'Miscellaneous', confidence: 0.35);
  }
}

class _Extracted<T> {
  final T value;
  final double confidence;

  const _Extracted({required this.value, required this.confidence});
}
