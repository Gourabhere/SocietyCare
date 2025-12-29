import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import '../services/task_service.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return TasksNotifier(ref.read(taskServiceProvider));
});

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskService _taskService;

  TasksNotifier(this._taskService) : super(const AsyncValue.loading());

  Future<void> loadTasks({
    String? blockId,
    String? floorId,
    String? flatId,
    TaskStatus? status,
  }) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _taskService.fetchTasks(
        blockId: blockId,
        floorId: floorId,
        flatId: flatId,
        status: status,
      );
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeTask({
    required String taskId,
    required String userId,
    required File photoFile,
    String? notes,
  }) async {
    try {
      final photoUrl = await _taskService.uploadTaskPhoto(photoFile, taskId);
      
      final updatedTask = await _taskService.completeTask(
        taskId: taskId,
        userId: userId,
        photoUrl: photoUrl,
        notes: notes,
      );

      state.whenData((tasks) {
        final updatedTasks = tasks.map((task) {
          if (task.id == taskId) {
            return updatedTask;
          }
          return task;
        }).toList();
        state = AsyncValue.data(updatedTasks);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> verifyTask({
    required String taskId,
    required String userId,
    String? notes,
  }) async {
    try {
      final updatedTask = await _taskService.verifyTask(
        taskId: taskId,
        userId: userId,
        notes: notes,
      );

      state.whenData((tasks) {
        final updatedTasks = tasks.map((task) {
          if (task.id == taskId) {
            return updatedTask;
          }
          return task;
        }).toList();
        state = AsyncValue.data(updatedTasks);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  void subscribeToTaskUpdates({String? blockId, String? floorId}) {
    _taskService.subscribeToTasks(blockId: blockId, floorId: floorId).listen(
      (tasks) {
        state = AsyncValue.data(tasks);
      },
      onError: (error, stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }
}

final recentActivityProvider = FutureProvider.family<List<ActivityLogModel>, String>(
  (ref, userId) async {
    final taskService = ref.read(taskServiceProvider);
    return taskService.fetchRecentActivity(userId);
  },
);

final taskDetailProvider = FutureProvider.family<TaskModel, String>(
  (ref, taskId) async {
    final taskService = ref.read(taskServiceProvider);
    return taskService.getTaskById(taskId);
  },
);
