import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/block_model.dart';

final blockServiceProvider = Provider<BlockService>((ref) {
  return BlockService();
});

class BlockService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BlockModel>> fetchBlocks(String societyId) async {
    try {
      final response = await _supabase
          .from('blocks')
          .select('''
            *,
            tasks!left(id, status)
          ''')
          .eq('society_id', societyId);

      return (response as List).map((block) {
        final blockData = Map<String, dynamic>.from(block);
        
        if (block['tasks'] != null) {
          final tasks = block['tasks'] as List;
          blockData['total_tasks'] = tasks.length;
          blockData['completed_tasks'] = tasks
              .where((t) => t['status'] == 'completed' || t['status'] == 'verified')
              .length;
          blockData['pending_tasks'] = tasks
              .where((t) => t['status'] == 'pending')
              .length;
          
          if (tasks.isEmpty) {
            blockData['status'] = 'pending';
          } else if (tasks.every((t) => t['status'] == 'verified')) {
            blockData['status'] = 'verified';
          } else if (tasks.any((t) => t['status'] == 'completed' || t['status'] == 'verified')) {
            blockData['status'] = 'in_progress';
          } else {
            blockData['status'] = 'pending';
          }
        }
        
        blockData.remove('tasks');
        return BlockModel.fromJson(blockData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch blocks: ${e.toString()}');
    }
  }

  Future<BlockModel> getBlockById(String blockId) async {
    try {
      final response = await _supabase
          .from('blocks')
          .select('''
            *,
            tasks!left(id, status)
          ''')
          .eq('id', blockId)
          .single();

      final blockData = Map<String, dynamic>.from(response);
      
      if (response['tasks'] != null) {
        final tasks = response['tasks'] as List;
        blockData['total_tasks'] = tasks.length;
        blockData['completed_tasks'] = tasks
            .where((t) => t['status'] == 'completed' || t['status'] == 'verified')
            .length;
        blockData['pending_tasks'] = tasks
            .where((t) => t['status'] == 'pending')
            .length;
      }
      
      blockData.remove('tasks');
      return BlockModel.fromJson(blockData);
    } catch (e) {
      throw Exception('Failed to fetch block: ${e.toString()}');
    }
  }
}
