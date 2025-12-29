import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

class TaskService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<List<TaskModel>> fetchTasks({
    String? blockId,
    String? floorId,
    String? flatId,
    TaskStatus? status,
  }) async {
    try {
      var query = _supabase
          .from('tasks')
          .select('''
            *,
            blocks!inner(block_number),
            floors(floor_number),
            flats(flat_number)
          ''');

      if (blockId != null) {
        query = query.eq('block_id', blockId);
      }
      if (floorId != null) {
        query = query.eq('floor_id', floorId);
      }
      if (flatId != null) {
        query = query.eq('flat_id', flatId);
      }
      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query;
      
      return (response as List).map((task) {
        final taskData = Map<String, dynamic>.from(task);
        if (task['blocks'] != null) {
          taskData['block_number'] = task['blocks']['block_number'];
        }
        if (task['floors'] != null) {
          taskData['floor_number'] = task['floors']['floor_number'];
        }
        if (task['flats'] != null) {
          taskData['flat_number'] = task['flats']['flat_number'];
        }
        return TaskModel.fromJson(taskData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: ${e.toString()}');
    }
  }

  Future<TaskModel> getTaskById(String taskId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('''
            *,
            blocks!inner(block_number),
            floors(floor_number),
            flats(flat_number)
          ''')
          .eq('id', taskId)
          .single();

      final taskData = Map<String, dynamic>.from(response);
      if (response['blocks'] != null) {
        taskData['block_number'] = response['blocks']['block_number'];
      }
      if (response['floors'] != null) {
        taskData['floor_number'] = response['floors']['floor_number'];
      }
      if (response['flats'] != null) {
        taskData['flat_number'] = response['flats']['flat_number'];
      }

      return TaskModel.fromJson(taskData);
    } catch (e) {
      throw Exception('Failed to fetch task: ${e.toString()}');
    }
  }

  Future<String> uploadTaskPhoto(File imageFile, String taskId) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExt';
      final filePath = 'tasks/$taskId/$fileName';

      await _supabase.storage
          .from(SupabaseConfig.storageBucket)
          .upload(filePath, imageFile);

      final photoUrl = _supabase.storage
          .from(SupabaseConfig.storageBucket)
          .getPublicUrl(filePath);

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: ${e.toString()}');
    }
  }

  Future<TaskModel> completeTask({
    required String taskId,
    required String userId,
    required String photoUrl,
    String? notes,
  }) async {
    try {
      final updatedTask = await _supabase
          .from('tasks')
          .update({
            'status': TaskStatus.completed.name,
            'completed_by_id': userId,
            'completed_at': DateTime.now().toIso8601String(),
            'photo_url': photoUrl,
            'notes': notes,
          })
          .eq('id', taskId)
          .select('''
            *,
            blocks!inner(block_number),
            floors(floor_number),
            flats(flat_number)
          ''')
          .single();

      await _supabase.from('task_history').insert({
        'id': _uuid.v4(),
        'task_id': taskId,
        'action': 'completed',
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'notes': notes,
      });

      final task = await getTaskById(taskId);

      await _createActivityLog(
        userId: userId,
        action: 'Completed ${task.taskTypeLabel}',
        location: 'Block ${task.blockNumber}, Floor ${task.floorNumber}',
        taskType: task.taskType.name,
        status: 'completed',
      );

      final taskData = Map<String, dynamic>.from(updatedTask);
      if (updatedTask['blocks'] != null) {
        taskData['block_number'] = updatedTask['blocks']['block_number'];
      }
      if (updatedTask['floors'] != null) {
        taskData['floor_number'] = updatedTask['floors']['floor_number'];
      }
      if (updatedTask['flats'] != null) {
        taskData['flat_number'] = updatedTask['flats']['flat_number'];
      }

      return TaskModel.fromJson(taskData);
    } catch (e) {
      throw Exception('Failed to complete task: ${e.toString()}');
    }
  }

  Future<TaskModel> verifyTask({
    required String taskId,
    required String userId,
    String? notes,
  }) async {
    try {
      final updatedTask = await _supabase
          .from('tasks')
          .update({
            'status': TaskStatus.verified.name,
            'verified_by_id': userId,
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId)
          .select('''
            *,
            blocks!inner(block_number),
            floors(floor_number),
            flats(flat_number)
          ''')
          .single();

      await _supabase.from('task_history').insert({
        'id': _uuid.v4(),
        'task_id': taskId,
        'action': 'verified',
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'notes': notes,
      });

      final task = await getTaskById(taskId);

      await _createActivityLog(
        userId: userId,
        action: 'Verified ${task.taskTypeLabel}',
        location: 'Block ${task.blockNumber}, Floor ${task.floorNumber}',
        taskType: task.taskType.name,
        status: 'verified',
      );

      final taskData = Map<String, dynamic>.from(updatedTask);
      if (updatedTask['blocks'] != null) {
        taskData['block_number'] = updatedTask['blocks']['block_number'];
      }
      if (updatedTask['floors'] != null) {
        taskData['floor_number'] = updatedTask['floors']['floor_number'];
      }
      if (updatedTask['flats'] != null) {
        taskData['flat_number'] = updatedTask['flats']['flat_number'];
      }

      return TaskModel.fromJson(taskData);
    } catch (e) {
      throw Exception('Failed to verify task: ${e.toString()}');
    }
  }

  Future<List<ActivityLogModel>> fetchRecentActivity(String userId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('activity_log')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(limit);

      return (response as List)
          .map((log) => ActivityLogModel.fromJson(log))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch activity: ${e.toString()}');
    }
  }

  Future<void> _createActivityLog({
    required String userId,
    required String action,
    required String location,
    String? taskType,
    String? status,
  }) async {
    try {
      await _supabase.from('activity_log').insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'action_description': action,
        'location': location,
        'timestamp': DateTime.now().toIso8601String(),
        'task_type': taskType,
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to create activity log: ${e.toString()}');
    }
  }

  Stream<List<TaskModel>> subscribeToTasks({
    String? blockId,
    String? floorId,
  }) {
    var query = _supabase.from('tasks').stream(primaryKey: ['id']);

    if (blockId != null) {
      query = query.eq('block_id', blockId);
    }
    if (floorId != null) {
      query = query.eq('floor_id', floorId);
    }

    return query.map((data) {
      return data.map((task) => TaskModel.fromJson(task)).toList();
    });
  }
}
