import 'package:intl/intl.dart';

class DateFormatterUtils {
  static final DateFormat _uiDate = DateFormat('d MMM y');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  static String formatUi(DateTime date) => _uiDate.format(date);

  static String formatIsoDate(DateTime date) => _isoDate.format(date);

  static DateTime parseSupabaseDate(dynamic value) {
    if (value == null) {
      throw const FormatException('Date is null');
    }

    if (value is DateTime) return value;
    final str = value.toString();
    return DateTime.parse(str);
  }

  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.isAfter(today);
  }
}
