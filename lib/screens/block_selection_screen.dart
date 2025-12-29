import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/block_model.dart';
import '../services/block_service.dart';
import '../widgets/progress_bar_widget.dart';
import 'floor_unit_list_screen.dart';

final blocksProvider = FutureProvider.family<List<BlockModel>, String>((ref, societyId) async {
  final blockService = ref.read(blockServiceProvider);
  return blockService.fetchBlocks(societyId);
});

class BlockSelectionScreen extends ConsumerStatefulWidget {
  final String societyId;

  const BlockSelectionScreen({
    super.key,
    this.societyId = 'default-society-id',
  });

  @override
  ConsumerState<BlockSelectionScreen> createState() => _BlockSelectionScreenState();
}

class _BlockSelectionScreenState extends ConsumerState<BlockSelectionScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final blocksAsync = ref.watch(blocksProvider(widget.societyId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Block'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(blocksProvider(widget.societyId));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.searchBlocks,
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: blocksAsync.when(
              data: (blocks) {
                final filteredBlocks = blocks.where((block) {
                  return block.blockNumber.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredBlocks.isEmpty) {
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
                          'No blocks found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBlocks.length,
                  itemBuilder: (context, index) {
                    return _buildBlockCard(filteredBlocks[index]);
                  },
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
                        ref.invalidate(blocksProvider(widget.societyId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockCard(BlockModel block) {
    final progress = block.progressPercentage / 100;
    
    Color statusColor;
    String statusLabel;
    
    if (block.status == 'verified') {
      statusColor = AppColors.verifiedDarkGreen;
      statusLabel = AppStrings.verified;
    } else if (block.status == 'in_progress') {
      statusColor = AppColors.primaryBlue;
      statusLabel = AppStrings.inProgress;
    } else {
      statusColor = AppColors.errorRed;
      statusLabel = AppStrings.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FloorUnitListScreen(
                blockId: block.id,
                blockNumber: block.blockNumber,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        block.blockNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.block} ${block.blockNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${block.completedTasks ?? 0} / ${block.totalTasks ?? 0} tasks',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProgressBarWidget(
                progress: progress,
                height: 8,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMiniStat(
                    Icons.door_front_door,
                    'Lobby',
                    block.completedTasks != null && block.completedTasks! > 0
                        ? AppStrings.completed
                        : AppStrings.pending,
                  ),
                  const SizedBox(width: 16),
                  _buildMiniStat(
                    Icons.layers,
                    'Floors',
                    '${block.totalTasks ?? 0}',
                  ),
                  const SizedBox(width: 16),
                  _buildMiniStat(
                    Icons.apartment,
                    'Flats',
                    '${block.totalTasks ?? 0}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.textGrey,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textGrey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
