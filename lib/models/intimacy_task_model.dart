import 'package:flutter/foundation.dart';

enum TaskType {
  couple,
  weekend,
  bounty,
}

enum TaskStatus {
  claimed,
  submitted,
  approved,
  rejected,
}

class IntimacyTask {
  final String id;
  final String? coupleId;
  final String? creatorId;
  final String title;
  final String? description;
  final int rewardPoints;
  final TaskType type;
  final DateTime createdAt;

  IntimacyTask({
    required this.id,
    this.coupleId,
    this.creatorId,
    required this.title,
    this.description,
    required this.rewardPoints,
    required this.type,
    required this.createdAt,
  });

  factory IntimacyTask.fromJson(Map<String, dynamic> json) {
    return IntimacyTask(
      id: json['id'],
      coupleId: json['couple_id'],
      creatorId: json['creator_id'],
      title: json['title'],
      description: json['description'],
      rewardPoints: json['reward_points'],
      type: TaskType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'couple_id': coupleId,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'reward_points': rewardPoints,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }
}

class TaskExecution {
  final String id;
  final String taskId;
  final String userId;
  final TaskStatus status;
  final String? proofImageUrl;
  final DateTime createdAt;
  final DateTime? completedAt;
  final IntimacyTask? task; // For convenience when fetching executions with task details

  TaskExecution({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.status,
    this.proofImageUrl,
    required this.createdAt,
    this.completedAt,
    this.task,
  });

  factory TaskExecution.fromJson(Map<String, dynamic> json) {
    return TaskExecution(
      id: json['id'],
      taskId: json['task_id'],
      userId: json['user_id'],
      status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
      proofImageUrl: json['proof_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      task: json['intimacy_tasks'] != null ? IntimacyTask.fromJson(json['intimacy_tasks']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'status': status.name,
      'proof_image_url': proofImageUrl,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  TaskExecution copyWith({
    String? id,
    String? taskId,
    String? userId,
    TaskStatus? status,
    String? proofImageUrl,
    DateTime? createdAt,
    DateTime? completedAt,
    IntimacyTask? task,
  }) {
    return TaskExecution(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      task: task ?? this.task,
    );
  }
}
