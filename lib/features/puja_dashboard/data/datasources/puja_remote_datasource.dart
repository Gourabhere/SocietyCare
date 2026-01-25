import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/supabase_config.dart';
import '../models/ai_extraction_model.dart';
import '../models/attachment_model.dart';
import '../models/transaction_model.dart';

class PujaRemoteDatasource {
  final SupabaseClient _client;

  const PujaRemoteDatasource(this._client);

  Stream<List<PujaTransactionModel>> watchTransactions() {
    return _client
        .from('puja_transactions')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .map((rows) => rows.map((r) => PujaTransactionModel.fromJson(r)).toList());
  }

  Future<List<PujaTransactionModel>> fetchTransactions({
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await _client
        .from('puja_transactions')
        .select()
        .order('date', ascending: false)
        .range(offset, offset + limit - 1);

    return (rows as List)
        .map((r) => PujaTransactionModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<PujaTransactionModel> createTransaction(PujaTransactionModel model) async {
    final row = await _client
        .from('puja_transactions')
        .insert(model.toInsertJson())
        .select()
        .single();

    return PujaTransactionModel.fromJson(row);
  }

  Future<PujaTransactionModel> updateTransaction(PujaTransactionModel model) async {
    final row = await _client
        .from('puja_transactions')
        .update(model.toUpdateJson())
        .eq('id', model.id)
        .select()
        .single();

    return PujaTransactionModel.fromJson(row);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _client.from('puja_transactions').delete().eq('id', transactionId);
  }

  Stream<List<PujaAttachmentModel>> watchAttachments(String transactionId) {
    return _client
        .from('puja_attachments')
        .stream(primaryKey: ['id'])
        .eq('transaction_id', transactionId)
        .order('uploaded_at', ascending: false)
        .map((rows) => rows.map((r) => PujaAttachmentModel.fromJson(r)).toList());
  }

  Future<PujaAttachmentModel> uploadAttachment({
    required String transactionId,
    required String filename,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final ext = filename.contains('.') ? filename.split('.').last : 'bin';
    final fileId = const Uuid().v4();
    final filePath = 'transactions/$transactionId/$fileId.$ext';

    await _client.storage.from(SupabaseConfig.pujaAttachmentsBucket).uploadBinary(
          filePath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );

    final row = await _client
        .from('puja_attachments')
        .insert({
          'transaction_id': transactionId,
          'file_path': filePath,
          'file_type': mimeType,
        })
        .select()
        .single();

    return PujaAttachmentModel.fromJson(row);
  }

  Future<void> deleteAttachment({
    required String attachmentId,
    required String filePath,
  }) async {
    await _client.storage.from(SupabaseConfig.pujaAttachmentsBucket).remove([filePath]);
    await _client.from('puja_attachments').delete().eq('id', attachmentId);
  }

  String getAttachmentPublicUrl(String filePath) {
    return _client.storage.from(SupabaseConfig.pujaAttachmentsBucket).getPublicUrl(filePath);
  }

  Future<AiProcessingLogModel> createAiLog({
    required String userId,
    required AiProcessingStatus status,
    required Map<String, dynamic> extractedData,
  }) async {
    final row = await _client
        .from('ai_processing_logs')
        .insert({
          'user_id': userId,
          'status': status.name,
          'extracted_data': extractedData,
        })
        .select()
        .single();

    return AiProcessingLogModel.fromJson(row);
  }

  Future<void> updateAiLogStatus({
    required String logId,
    required AiProcessingStatus status,
  }) async {
    await _client.from('ai_processing_logs').update({'status': status.name}).eq('id', logId);
  }

  Future<List<Map<String, dynamic>>> listUsers() async {
    final rows = await _client.from('users').select('id,email,role,name,created_at');
    return (rows as List).map((r) => r as Map<String, dynamic>).toList();
  }

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    await _client.from('users').update({'role': role}).eq('id', userId);
  }

  Future<void> logAdminAction({
    required String userId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    await _client.from('activity_log').insert({
      'user_id': userId,
      'action_description': action,
      'location': 'Puja Dashboard',
      'metadata': metadata,
    });
  }
}
