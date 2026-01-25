import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/puja_categories.dart';
import '../../../../constants/puja_strings.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../utils/date_formatter_utils.dart';
import '../../data/models/ai_extraction_model.dart';
import '../../domain/entities/ai_extraction.dart';
import '../../domain/entities/transaction.dart';
import '../providers/puja_dependencies.dart';
import '../providers/puja_permissions_provider.dart';

class AiPreviewConfirmationScreen extends ConsumerStatefulWidget {
  final List<int> imageBytes;
  final String mimeType;
  final String originalFilename;
  final AiExtractionResult result;

  const AiPreviewConfirmationScreen({
    super.key,
    required this.imageBytes,
    required this.mimeType,
    required this.originalFilename,
    required this.result,
  });

  @override
  ConsumerState<AiPreviewConfirmationScreen> createState() => _AiPreviewConfirmationScreenState();
}

class _AiPreviewConfirmationScreenState extends ConsumerState<AiPreviewConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();

  late PujaTransactionType _type;
  String? _category;
  late final TextEditingController _amountController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  DateTime _date = DateTime.now();

  bool _saving = false;
  String? _aiLogId;

  @override
  void initState() {
    super.initState();
    _type = widget.result.transactionType;
    _category = widget.result.category;
    _amountController = TextEditingController(
      text: widget.result.amount != null ? widget.result.amount!.toStringAsFixed(2) : '',
    );
    _nameController = TextEditingController(text: widget.result.donorPayerName ?? '');
    _descriptionController = TextEditingController();
    if (widget.result.date != null) {
      _date = widget.result.date!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _createAiLog());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(pujaIsAdminProvider);
    final categories = PujaCategories.forType(_type);

    return Scaffold(
      appBar: AppBar(title: const Text(PujaStrings.reviewAndConfirm)),
      body: AbsorbPointer(
        absorbing: _saving,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      Uint8List.fromList(widget.imageBytes),
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Extracted fields (editable)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _ConfidenceRow(
                label: 'Amount',
                confidence: widget.result.amountConfidence,
              ),
              _ConfidenceRow(
                label: 'Name',
                confidence: widget.result.nameConfidence,
              ),
              _ConfidenceRow(
                label: 'Date',
                confidence: widget.result.dateConfidence,
              ),
              _ConfidenceRow(
                label: 'Category',
                confidence: widget.result.categoryConfidence,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PujaTransactionType>(
                value: _type,
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
                  if (v == null) return;
                  setState(() {
                    _type = v;
                    _category = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: PujaStrings.category),
                items: [
                  for (final c in categories) DropdownMenuItem(value: c, child: Text(c)),
                ],
                validator: (v) => (v == null || v.isEmpty) ? 'Please select a category' : null,
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: PujaStrings.amount, prefixText: '₹ '),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final parsed = double.tryParse((v ?? '').trim());
                  if (parsed == null) return 'Enter a valid amount';
                  if (parsed <= 0) return 'Amount must be positive';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: PujaStrings.name),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(PujaStrings.date),
                subtitle: Text(DateFormatterUtils.formatUi(_date)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: PujaStrings.description),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              if (!isAdmin)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'You have read-only access. Ask an admin to confirm & save.',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _reject,
                      child: const Text(PujaStrings.reject),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (!isAdmin || _saving) ? null : _confirm,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(PujaStrings.confirm),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Raw extracted text'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.result.rawText.isEmpty ? '(empty)' : widget.result.rawText,
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAiLog() async {
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      final remote = ref.read(pujaRemoteDatasourceProvider);
      final log = await remote.createAiLog(
        userId: user.id,
        status: AiProcessingStatus.pending,
        extractedData: widget.result.toJson(),
      );
      if (!mounted) return;
      setState(() => _aiLogId = log.id);
    } catch (_) {
      // Non-blocking
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
    });
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    if (DateFormatterUtils.isFutureDate(_date)) {
      Fluttertoast.showToast(msg: 'Date cannot be in the future');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(pujaRepositoryProvider);
      final tx = await repo.createTransaction(
        type: _type,
        category: _category!,
        amount: double.parse(_amountController.text.trim()),
        donorPayerName: _nameController.text.trim(),
        date: _date,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await repo.uploadAttachment(
        transactionId: tx.id,
        filename: widget.originalFilename,
        bytes: widget.imageBytes,
        mimeType: widget.mimeType,
      );

      if (_aiLogId != null) {
        await ref.read(pujaRemoteDatasourceProvider).updateAiLogStatus(
              logId: _aiLogId!,
              status: AiProcessingStatus.confirmed,
            );
      }

      Fluttertoast.showToast(msg: 'Transaction created');
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reject() async {
    try {
      if (_aiLogId != null) {
        await ref.read(pujaRemoteDatasourceProvider).updateAiLogStatus(
              logId: _aiLogId!,
              status: AiProcessingStatus.rejected,
            );
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _ConfidenceRow extends StatelessWidget {
  final String label;
  final double confidence;

  const _ConfidenceRow({
    required this.label,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).clamp(0, 100).toStringAsFixed(0);
    final color = confidence >= 0.85
        ? AppColors.successGreen
        : (confidence >= 0.6 ? AppColors.warningOrange : AppColors.errorRed);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: confidence.clamp(0, 1),
              color: color,
              backgroundColor: AppColors.dividerGrey,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 44, child: Text('$pct%')),
        ],
      ),
    );
  }
}
