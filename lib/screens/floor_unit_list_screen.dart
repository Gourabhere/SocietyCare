import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_execution_screen.dart';

class FloorUnitListScreen extends ConsumerStatefulWidget {
  final String blockId;
  final String blockNumber;

  const FloorUnitListScreen({
    super.key,
    required this.blockId,
    required this.blockNumber,
  });

  @override
  ConsumerState<FloorUnitListScreen> createState() => _FloorUnitListScreenState();
}

class _FloorUnitListScreenState extends ConsumerState<FloorUnitListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksProvider.notifier).loadTasks(blockId: widget.blockId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${AppStrings.block} ${widget.blockNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(tasksProvider.notifier).loadTasks(blockId: widget.blockId);
            },
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: AppColors.textLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tasks found',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          final lobbyTasks = tasks.where((t) => 
              t.floorNumber == null || t.floorNumber == '0' || t.floorNumber == 'Lobby'
          ).toList();

          final floorTasksMap = <String, List<TaskModel>>{};
          for (final task in tasks) {
            if (task.floorNumber != null && 
                task.floorNumber != '0' && 
                task.floorNumber != 'Lobby') {
              floorTasksMap.putIfAbsent(task.floorNumber!, () => []).add(task);
            }
          }

          final floors = floorTasksMap.keys.toList()..sort();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lobbyTasks.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      AppStrings.lobby,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  ...lobbyTasks.map((task) => _buildTaskCard(task)),
                  const SizedBox(height: 16),
                ],
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Floors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: floors.length,
                    itemBuilder: (context, index) {
                      final floorNumber = floors[index];
                      final floorTasks = floorTasksMap[floorNumber]!;
                      final allCompleted = floorTasks.every((t) => 
                          t.status == TaskStatus.completed || 
                          t.status == TaskStatus.verified);
                      
                      return _buildFloorCard(floorNumber, allCompleted);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Error: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(tasksProvider.notifier).loadTasks(blockId: widget.blockId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskExecutionScreen(taskId: task.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _getTaskIcon(task.taskType),
                size: 32,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskTypeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (task.assigneeName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.assigneeName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusIndicator(task.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloorCard(String floorNumber, bool isCompleted) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskExecutionScreen(
                blockId: widget.blockId,
                floorNumber: floorNumber,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.successGreen.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted ? AppColors.successGreen : AppColors.dividerGrey,
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.access_time,
                size: 32,
                color: isCompleted ? AppColors.successGreen : AppColors.warningOrange,
              ),
              const SizedBox(height: 8),
              Text(
                '${AppStrings.floor} $floorNumber',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? AppColors.successGreen : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(TaskStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case TaskStatus.pending:
        color = AppColors.errorRed;
        icon = Icons.pending;
        break;
      case TaskStatus.completed:
        color = AppColors.successGreen;
        icon = Icons.check_circle;
        break;
      case TaskStatus.verified:
        color = AppColors.verifiedDarkGreen;
        icon = Icons.verified;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.brooming:
        return Icons.cleaning_services;
      case TaskType.mopping:
        return Icons.water_drop;
      case TaskType.garbage:
        return Icons.delete_outline;
    }
  }
}
