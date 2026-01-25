import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../constants/app_colors.dart';
import '../../../../utils/export_utils.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/export_to_csv_usecase.dart';
import '../providers/dashboard_provider.dart';
import '../providers/transaction_provider.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  final _sheetIdController = TextEditingController();
  final _sheetNameController = TextEditingController(text: 'Sheet1');
  bool _exporting = false;

  @override
  void dispose() {
    _sheetIdController.dispose();
    _sheetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(pujaFilteredTransactionsProvider);
    final statsAsync = ref.watch(pujaDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: AbsorbPointer(
        absorbing: _exporting,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Exports respect the current filters from the Transactions screen.',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.table_view),
                title: const Text('Export CSV'),
                subtitle: Text('${transactions.length} rows'),
                onTap: _exporting ? null : () => _exportCsv(transactions),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export PDF report'),
                subtitle: const Text('Summary + recent transactions'),
                onTap: _exporting
                    ? null
                    : () async {
                        try {
                          final stats = await ref.read(pujaDashboardStatsProvider.future);
                          await _exportPdf(stats, transactions);
                        } catch (e) {
                          Fluttertoast.showToast(msg: 'Failed to load stats: $e');
                        }
                      },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Google Sheets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sheetIdController,
              decoration: const InputDecoration(
                labelText: 'Spreadsheet ID',
                hintText: 'From the Google Sheets URL',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sheetNameController,
              decoration: const InputDecoration(labelText: 'Sheet name'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _exporting ? null : () => _exportToGoogleSheets(transactions),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Append to Google Sheet'),
            ),
            const SizedBox(height: 12),
            Text(
              statsAsync.isLoading
                  ? 'Loading stats...'
                  : 'Tip: On mobile/web, configure Google Sign-In OAuth client IDs for Sheets export.',
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv(List<PujaTransaction> transactions) async {
    setState(() => _exporting = true);
    try {
      final csvStr = const ExportToCsvUsecase().call(transactions);
      final bytes = utf8.encode(csvStr);
      final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      await ExportUtils.saveAndShareBytes(
        filename: 'puja_transactions_$ts.csv',
        bytes: bytes,
        mimeType: 'text/csv',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportPdf(PujaDashboardStats stats, List<PujaTransaction> transactions) async {
    setState(() => _exporting = true);
    try {
      final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
      final doc = pw.Document();
      final ts = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              pw.Text(
                'Hijibiji 2026 Saraswati Puja - Report',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Exported at: $ts'),
              pw.SizedBox(height: 16),
              pw.Text('Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: const ['Metric', 'Value'],
                data: [
                  ['Total Collections', currency.format(stats.totalCollections)],
                  ['Total Expenses', currency.format(stats.totalExpenses)],
                  ['Net Balance', currency.format(stats.balance)],
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Transactions (first 50)',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: const ['Type', 'Category', 'Amount', 'Name', 'Date', 'Description'],
                data: [
                  for (final t in transactions.take(50))
                    [
                      t.type.name,
                      t.category,
                      t.amount.toStringAsFixed(2),
                      t.donorPayerName,
                      t.date.toIso8601String().split('T').first,
                      t.description ?? '',
                    ],
                ],
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              ),
            ];
          },
        ),
      );

      final bytes = await doc.save();
      final name = 'puja_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      await ExportUtils.saveAndShareBytes(
        filename: name,
        bytes: bytes,
        mimeType: 'application/pdf',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'PDF export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportToGoogleSheets(List<PujaTransaction> transactions) async {
    final spreadsheetId = _sheetIdController.text.trim();
    final sheetName = _sheetNameController.text.trim().isEmpty ? 'Sheet1' : _sheetNameController.text.trim();

    if (spreadsheetId.isEmpty) {
      Fluttertoast.showToast(msg: 'Spreadsheet ID is required');
      return;
    }

    setState(() => _exporting = true);
    try {
      final signIn = GoogleSignIn(scopes: [SheetsApi.spreadsheetsScope]);
      final account = await signIn.signIn();
      if (account == null) {
        Fluttertoast.showToast(msg: 'Sign-in cancelled');
        return;
      }

      final gapis.AuthClient? client = await signIn.authenticatedClient();
      if (client == null) {
        Fluttertoast.showToast(msg: 'Failed to create authenticated client');
        return;
      }

      final api = SheetsApi(client);

      final rows = <List<Object?>>[
        ['Type', 'Category', 'Amount', 'Name', 'Date', 'Description', 'Exported At'],
        for (final t in transactions)
          [
            t.type.name,
            t.category,
            t.amount,
            t.donorPayerName,
            t.date.toIso8601String().split('T').first,
            t.description ?? '',
            DateTime.now().toIso8601String(),
          ],
      ];

      final valueRange = ValueRange(values: rows);
      await api.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        '$sheetName!A1',
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );

      Fluttertoast.showToast(msg: 'Exported to Google Sheets');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Google Sheets export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}
