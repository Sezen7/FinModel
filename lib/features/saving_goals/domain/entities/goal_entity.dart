import 'package:equatable/equatable.dart';

class GoalEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadlineDate;
  final DateTime createdAt;
  final String colorHex;
  final double monthlyContribution;
  final int durationMonths;
  final List<double> progressHistory;
  final bool isCompleted;
  final DateTime? completionDate;

  const GoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadlineDate,
    required this.createdAt,
    required this.colorHex,
    this.monthlyContribution = 0.0,
    this.durationMonths = 0,
    this.progressHistory = const [],
    this.isCompleted = false,
    this.completionDate,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        targetAmount,
        currentAmount,
        deadlineDate,
        createdAt,
        colorHex,
        monthlyContribution,
        durationMonths,
        progressHistory,
        isCompleted,
        completionDate,
      ];
}
