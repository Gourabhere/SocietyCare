import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/puja_categories.dart';
import '../../../../constants/puja_strings.dart';
import '../../../../utils/date_formatter_utils.dart';
import '../../domain/entities/transaction.dart';
import '../providers/puja_dependencies.dart';
import '../providers/puja_permissions_provider.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final PujaTransaction transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late PujaTransactionType _type;
  String? _category;
  late DateTime _date;
  final List<XFile> _newAttachments = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction.type;
    _category = widget.transaction.category;
    _date = widget.transaction.date;
    _amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));
    _nameController = TextEditingController(text: widget.transaction.donorPayerName);
    _descriptionController = TextEditingController(text: widget.transaction.description ?? '');
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
      appBar: AppBar(
        title: const Text(PujaStrings.editTransaction),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.errorRed),
              onPressed: _submitting ? null : _confirmDelete,
            ),
        ],
      ),
      body: isAdmin
          ? _buildForm(categories)
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  PujaStrings.readOnlyHint,
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ),
    );
  }

  Widget _buildForm(List<String> categories) {
    return AbsorbPointer(
      absorbing: _submitting,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: PujaStrings.amount,
                prefixText: '₹ ',
              ),
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
            const SizedBox(height: 12),
            _buildAttachmentsSection(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(PujaStrings.update),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'New attachments',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton.icon(
              onPressed: _pickAttachments,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add'),
            ),
          ],
        ),
        if (_newAttachments.isEmpty)
          const Text(
            'No new attachments',
            style: TextStyle(color: AppColors.textGrey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in _newAttachments)
                Chip(
                  label: Text(a.name, overflow: TextOverflow.ellipsis),
                  onDeleted: () => setState(() => _newAttachments.remove(a)),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickAttachments() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    setState(() {
      _newAttachments.addAll(files);
    });
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (DateFormatterUtils.isFutureDate(_date)) {
      Fluttertoast.showToast(msg: 'Date cannot be in the future');
      return;
    }

    final amount = double.parse(_amountController.text.trim());

    setState(() => _submitting = true);

    try {
      final repo = ref.read(pujaRepositoryProvider);
      final updated = await repo.updateTransaction(
        widget.transaction.copyWith(
          type: _type,
          category: _category!,
          amount: amount,
          donorPayerName: _nameController.text.trim(),
          date: _date,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );

      for (final a in _newAttachments) {
        final bytes = await a.readAsBytes();
        await repo.uploadAttachment(
          transactionId: updated.id,
          filename: a.name,
          bytes: bytes,
          mimeType: _guessMime(a.name),
        );
      }

      Fluttertoast.showToast(msg: 'Updated');
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed: $e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(PujaStrings.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text(PujaStrings.delete),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _submitting = true);
    try {
      final repo = ref.read(pujaRepositoryProvider);
      await repo.deleteTransaction(widget.transaction.id);
      Fluttertoast.showToast(msg: 'Deleted');
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed: $e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String _guessMime(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}
