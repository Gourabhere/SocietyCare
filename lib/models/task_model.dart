enum TaskType { brooming, mopping, garbage }

enum TaskStatus { pending, completed, verified }

class TaskModel {
  final String id;
  final String? flatId;
  final String? floorId;
  final String blockId;
  final String societyId;
  final TaskType taskType;
  final TaskStatus status;
  final String? assigneeId;
  final String? completedById;
  final String? verifiedById;
  final DateTime? completedAt;
  final DateTime? verifiedAt;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;
  
  final String? assigneeName;
  final String? completedByName;
  final String? verifiedByName;
  final String? blockNumber;
  final String? floorNumber;
  final String? flatNumber;

  TaskModel({
    required this.id,
    this.flatId,
    this.floorId,
    required this.blockId,
    required this.societyId,
    required this.taskType,
    required this.status,
    this.assigneeId,
    this.completedById,
    this.verifiedById,
    this.completedAt,
    this.verifiedAt,
    this.notes,
    this.photoUrl,
    required this.createdAt,
    this.assigneeName,
    this.completedByName,
    this.verifiedByName,
    this.blockNumber,
    this.floorNumber,
    this.flatNumber,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      flatId: json['flat_id'] as String?,
      floorId: json['floor_id'] as String?,
      blockId: json['block_id'] as String,
      societyId: json['society_id'] as String,
      taskType: _parseTaskType(json['task_type'] as String),
      status: _parseTaskStatus(json['status'] as String),
      assigneeId: json['assignee_id'] as String?,
      completedById: json['completed_by_id'] as String?,
      verifiedById: json['verified_by_id'] as String?,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      verifiedAt: json['verified_at'] != null 
          ? DateTime.parse(json['verified_at'] as String) 
          : null,
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      assigneeName: json['assignee_name'] as String?,
      completedByName: json['completed_by_name'] as String?,
      verifiedByName: json['verified_by_name'] as String?,
      blockNumber: json['block_number'] as String?,
      floorNumber: json['floor_number'] as String?,
      flatNumber: json['flat_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flat_id': flatId,
      'floor_id': floorId,
      'block_id': blockId,
      'society_id': societyId,
      'task_type': taskType.name,
      'status': status.name,
      'assignee_id': assigneeId,
      'completed_by_id': completedById,
      'verified_by_id': verifiedById,
      'completed_at': completedAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'notes': notes,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static TaskType _parseTaskType(String type) {
    switch (type) {
      case 'brooming':
        return TaskType.brooming;
      case 'mopping':
        return TaskType.mopping;
      case 'garbage':
        return TaskType.garbage;
      default:
        return TaskType.brooming;
    }
  }

  static TaskStatus _parseTaskStatus(String status) {
    switch (status) {
      case 'pending':
        return TaskStatus.pending;
      case 'completed':
        return TaskStatus.completed;
      case 'verified':
        return TaskStatus.verified;
      default:
        return TaskStatus.pending;
    }
  }

  String get taskTypeLabel {
    switch (taskType) {
      case TaskType.brooming:
        return 'Floor Brooming';
      case TaskType.mopping:
        return 'Floor Mopping';
      case TaskType.garbage:
        return 'Garbage Collection';
    }
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.verified:
        return 'Verified';
    }
  }

  TaskModel copyWith({
    String? id,
    String? flatId,
    String? floorId,
    String? blockId,
    String? societyId,
    TaskType? taskType,
    TaskStatus? status,
    String? assigneeId,
    String? completedById,
    String? verifiedById,
    DateTime? completedAt,
    DateTime? verifiedAt,
    String? notes,
    String? photoUrl,
    DateTime? createdAt,
    String? assigneeName,
    String? completedByName,
    String? verifiedByName,
    String? blockNumber,
    String? floorNumber,
    String? flatNumber,
  }) {
    return TaskModel(
      id: id ?? this.id,
      flatId: flatId ?? this.flatId,
      floorId: floorId ?? this.floorId,
      blockId: blockId ?? this.blockId,
      societyId: societyId ?? this.societyId,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      assigneeId: assigneeId ?? this.assigneeId,
      completedById: completedById ?? this.completedById,
      verifiedById: verifiedById ?? this.verifiedById,
      completedAt: completedAt ?? this.completedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      assigneeName: assigneeName ?? this.assigneeName,
      completedByName: completedByName ?? this.completedByName,
      verifiedByName: verifiedByName ?? this.verifiedByName,
      blockNumber: blockNumber ?? this.blockNumber,
      floorNumber: floorNumber ?? this.floorNumber,
      flatNumber: flatNumber ?? this.flatNumber,
    );
  }
}
