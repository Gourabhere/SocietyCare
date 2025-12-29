import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/progress_bar_widget.dart';
import 'block_selection_screen.dart';
import 'login_screen.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(tasksProvider.notifier).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(currentUserProvider.notifier).signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              currentUserAsync.when(
                data: (user) => _buildHeader(user?.name ?? 'User'),
                loading: () => _buildHeader('Loading...'),
                error: (_, __) => _buildHeader('User'),
              ),
              const SizedBox(height: 24),
              tasksAsync.when(
                data: (tasks) => _buildTaskCategories(tasks),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.errorRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading tasks: ${error.toString()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.errorRed),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              currentUserAsync.when(
                data: (user) {
                  if (user != null) {
                    return _buildRecentActivity(user.id);
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d, y').format(now);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $userName',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.sync,
                size: 16,
                color: AppColors.textGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '${AppStrings.lastSync}: ${DateFormat('hh:mm a').format(now)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCategories(List<TaskModel> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => 
        t.status == TaskStatus.completed || t.status == TaskStatus.verified).length;
    final pendingTasks = tasks.where((t) => t.status == TaskStatus.pending).length;

    final societyTasks = tasks.where((t) => t.flatId == null && t.floorId == null).toList();
    final blockTasks = tasks.where((t) => t.floorId == null && t.flatId == null).toList();
    final floorTasks = tasks.where((t) => t.floorId != null && t.flatId == null).toList();
    final flatTasks = tasks.where((t) => t.flatId != null).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            title: AppStrings.societyWideTasks,
            tasks: societyTasks,
            icon: Icons.apartment,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BlockSelectionScreen(),
                ),
              );
            },
          ),
          _buildCategoryCard(
            title: AppStrings.blockTasks,
            tasks: blockTasks,
            icon: Icons.business,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BlockSelectionScreen(),
                ),
              );
            },
          ),
          _buildCategoryCard(
            title: AppStrings.floorTasks,
            tasks: floorTasks,
            icon: Icons.layers,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BlockSelectionScreen(),
                ),
              );
            },
          ),
          _buildCategoryCard(
            title: AppStrings.flatTasks,
            tasks: flatTasks,
            icon: Icons.door_front_door,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BlockSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required List<TaskModel> tasks,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => 
        t.status == TaskStatus.completed || t.status == TaskStatus.verified).length;
    final pendingTasks = tasks.where((t) => t.status == TaskStatus.pending).length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedTasks / $totalTasks tasks',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textGrey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProgressBarWidget(
                progress: progress,
                height: 8,
              ),
              const SizedBox(height: 12),
              if (pendingTasks > 0)
                Text(
                  '$pendingTasks ${AppStrings.pending}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(String userId) {
    final activityAsync = ref.watch(recentActivityProvider(userId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.recentActivity,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          activityAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No recent activity',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getActivityIcon(activity.status),
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      activity.actionDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      activity.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          activity.timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (activity.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(activity.status!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              activity.status!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Failed to load activity',
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? status) {
    if (status == 'completed') return Icons.check_circle;
    if (status == 'verified') return Icons.verified;
    return Icons.task_alt;
  }

  Color _getStatusColor(String status) {
    if (status == 'completed') return AppColors.successGreen;
    if (status == 'verified') return AppColors.verifiedDarkGreen;
    return AppColors.primaryBlue;
  }
}
