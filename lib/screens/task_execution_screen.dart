import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/custom_button.dart';

class TaskExecutionScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final String? blockId;
  final String? floorNumber;

  const TaskExecutionScreen({
    super.key,
    this.taskId,
    this.blockId,
    this.floorNumber,
  });

  @override
  ConsumerState<TaskExecutionScreen> createState() => _TaskExecutionScreenState();
}

class _TaskExecutionScreenState extends ConsumerState<TaskExecutionScreen> {
  TaskModel? _selectedTask;
  File? _selectedImage;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.blockId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tasksProvider.notifier).loadTasks(blockId: widget.blockId);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to pick image: ${e.toString()}',
        backgroundColor: AppColors.errorRed,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.addPhoto,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                title: const Text(AppStrings.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
                title: const Text(AppStrings.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitTask() async {
    if (_selectedTask == null) return;

    if (_selectedImage == null) {
      Fluttertoast.showToast(
        msg: AppStrings.photoRequired,
        backgroundColor: AppColors.errorRed,
        textColor: Colors.white,
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(tasksProvider.notifier).completeTask(
        taskId: _selectedTask!.id,
        userId: currentUser.id,
        photoFile: _selectedImage!,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: AppStrings.taskMarkedComplete,
        backgroundColor: AppColors.successGreen,
        textColor: Colors.white,
      );

      setState(() {
        _selectedTask = null;
        _selectedImage = null;
        _notesController.clear();
      });

      ref.read(tasksProvider.notifier).loadTasks(blockId: widget.blockId);
    } catch (e) {
      if (!mounted) return;
      
      Fluttertoast.showToast(
        msg: 'Failed to complete task: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppColors.errorRed,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showCompleteTaskModal(TaskModel task) {
    setState(() {
      _selectedTask = task;
      _selectedImage = null;
      _notesController.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        AppStrings.markComplete,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedTask = null;
                            _selectedImage = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.taskTypeLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppStrings.block} ${task.blockNumber}, ${AppStrings.floor} ${task.floorNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '${AppStrings.addPhoto} *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedImage == null 
                                    ? AppColors.dividerGrey 
                                    : AppColors.primaryBlue,
                                width: 2,
                              ),
                            ),
                            child: _selectedImage == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 48,
                                        color: AppColors.textGrey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tap to add photo',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '${AppStrings.addNotes} (${AppStrings.notesPlaceholder})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: AppStrings.notesPlaceholder,
                            hintStyle: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: AppStrings.markComplete,
                          onPressed: () {
                            Navigator.pop(context);
                            _submitTask();
                          },
                          isLoading: _isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactSupervisor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.contactSupervisor),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supervisor Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Phone',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '+1 234 567 8900',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Available Hours',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '8:00 AM - 8:00 PM',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
          ElevatedButton(
            onPressed: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: '+1234567890');
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              }
            },
            child: const Text(AppStrings.callNow),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.taskId != null) {
      return _buildSingleTaskView();
    } else {
      return _buildMultipleTasksView();
    }
  }

  Widget _buildSingleTaskView() {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId!));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: taskAsync.when(
        data: (task) => SingleChildScrollView(
          child: Column(
            children: [
              _buildTaskHeader(task),
              const SizedBox(height: 16),
              TaskCard(
                task: task,
                onComplete: () => _showCompleteTaskModal(task),
                onVerify: currentUser?.role.name == 'admin'
                    ? () async {
                        await ref.read(tasksProvider.notifier).verifyTask(
                          taskId: task.id,
                          userId: currentUser!.id,
                        );
                        Fluttertoast.showToast(
                          msg: AppStrings.taskVerified,
                          backgroundColor: AppColors.successGreen,
                        );
                      }
                    : null,
              ),
              if (task.photoUrl != null) ...[
                const SizedBox(height: 16),
                _buildPhotoSection(task.photoUrl!),
              ],
              if (task.notes != null) ...[
                const SizedBox(height: 16),
                _buildNotesSection(task.notes!),
              ],
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: AppStrings.contactSupervisor,
                  onPressed: _showContactSupervisor,
                  outlined: true,
                  icon: Icons.phone,
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildMultipleTasksView() {
    final tasksAsync = ref.watch(tasksProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${AppStrings.block} Tasks'),
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
                  Icon(Icons.inbox, size: 64, color: AppColors.textLight),
                  SizedBox(height: 16),
                  Text(
                    'No tasks found',
                    style: TextStyle(fontSize: 16, color: AppColors.textGrey),
                  ),
                ],
              ),
            );
          }

          final filteredTasks = widget.floorNumber != null
              ? tasks.where((t) => t.floorNumber == widget.floorNumber).toList()
              : tasks;

          final totalTasks = filteredTasks.length;
          final completedTasks = filteredTasks
              .where((t) => t.status != TaskStatus.pending)
              .length;

          return Column(
            children: [
              _buildProgressHeader(completedTasks, totalTasks),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TaskExecutionScreen(taskId: task.id),
                          ),
                        );
                      },
                      onComplete: () => _showCompleteTaskModal(task),
                      onVerify: currentUser?.role.name == 'admin'
                          ? () async {
                              await ref.read(tasksProvider.notifier).verifyTask(
                                taskId: task.id,
                                userId: currentUser!.id,
                              );
                              Fluttertoast.showToast(
                                msg: AppStrings.taskVerified,
                                backgroundColor: AppColors.successGreen,
                              );
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
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

  Widget _buildTaskHeader(TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.lightBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.block} ${task.blockNumber}, ${AppStrings.floor} ${task.floorNumber}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.taskTypeLabel,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.lightBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ProgressBarWidget(
            progress: progress,
            height: 10,
            showPercentage: true,
          ),
          const SizedBox(height: 8),
          Text(
            '$completed / $total tasks completed',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(String photoUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completion Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              placeholder: (context, url) => Container(
                height: 200,
                color: AppColors.cardBackground,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppColors.cardBackground,
                child: const Icon(Icons.error, color: AppColors.errorRed),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              notes,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
