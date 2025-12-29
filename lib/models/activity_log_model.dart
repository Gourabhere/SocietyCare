class ActivityLogModel {
  final String id;
  final String userId;
  final String actionDescription;
  final String location;
  final DateTime timestamp;
  final String? taskType;
  final String? status;

  ActivityLogModel({
    required this.id,
    required this.userId,
    required this.actionDescription,
    required this.location,
    required this.timestamp,
    this.taskType,
    this.status,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      actionDescription: json['action_description'] as String,
      location: json['location'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      taskType: json['task_type'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'action_description': actionDescription,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'task_type': taskType,
      'status': status,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
