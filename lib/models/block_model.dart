class BlockModel {
  final String id;
  final String societyId;
  final String blockNumber;
  final DateTime createdAt;
  
  final int? totalTasks;
  final int? completedTasks;
  final int? pendingTasks;
  final String? status;

  BlockModel({
    required this.id,
    required this.societyId,
    required this.blockNumber,
    required this.createdAt,
    this.totalTasks,
    this.completedTasks,
    this.pendingTasks,
    this.status,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      id: json['id'] as String,
      societyId: json['society_id'] as String,
      blockNumber: json['block_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalTasks: json['total_tasks'] as int?,
      completedTasks: json['completed_tasks'] as int?,
      pendingTasks: json['pending_tasks'] as int?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'society_id': societyId,
      'block_number': blockNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get progressPercentage {
    if (totalTasks == null || totalTasks == 0) return 0.0;
    return (completedTasks ?? 0) / totalTasks! * 100;
  }

  BlockModel copyWith({
    String? id,
    String? societyId,
    String? blockNumber,
    DateTime? createdAt,
    int? totalTasks,
    int? completedTasks,
    int? pendingTasks,
    String? status,
  }) {
    return BlockModel(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      blockNumber: blockNumber ?? this.blockNumber,
      createdAt: createdAt ?? this.createdAt,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      status: status ?? this.status,
    );
  }
}
