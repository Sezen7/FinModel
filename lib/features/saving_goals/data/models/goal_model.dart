import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.targetAmount,
    required super.currentAmount,
    required super.deadlineDate,
    required super.createdAt,
    required super.colorHex,
    super.monthlyContribution,
    super.durationMonths,
    super.progressHistory,
    super.isCompleted,
    super.completionDate,
  });

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadlineDate: entity.deadlineDate,
      createdAt: entity.createdAt,
      colorHex: entity.colorHex,
      monthlyContribution: entity.monthlyContribution,
      durationMonths: entity.durationMonths,
      progressHistory: entity.progressHistory,
      isCompleted: entity.isCompleted,
      completionDate: entity.completionDate,
    );
  }

  factory GoalModel.fromJson(Map<String, dynamic> json, String documentId) {
    return GoalModel(
      id: documentId,
      userId: json['userId'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      deadlineDate: (json['deadlineDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      colorHex: json['colorHex'] as String,
      monthlyContribution: (json['monthlyContribution'] as num?)?.toDouble() ?? 0.0,
      durationMonths: json['durationMonths'] as int? ?? 0,
      progressHistory: (json['progressHistory'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      isCompleted: json['isCompleted'] as bool? ?? false,
      completionDate: (json['completionDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadlineDate': Timestamp.fromDate(deadlineDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'colorHex': colorHex,
      'monthlyContribution': monthlyContribution,
      'durationMonths': durationMonths,
      'progressHistory': progressHistory,
      'isCompleted': isCompleted,
      'completionDate':
          completionDate != null ? Timestamp.fromDate(completionDate!) : null,
    };
  }
}
