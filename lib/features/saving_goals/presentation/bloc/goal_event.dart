import 'package:equatable/equatable.dart';
import '../../domain/entities/goal_entity.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();
  @override
  List<Object?> get props => [];
}

class LoadGoalsEvent extends GoalEvent {
  final String userId;
  const LoadGoalsEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AddGoalSubmitEvent extends GoalEvent {
  final GoalEntity goal;
  const AddGoalSubmitEvent(this.goal);
  @override
  List<Object?> get props => [goal];
}

class AddProgressEvent extends GoalEvent {
  final GoalEntity goal;
  final double addedAmount;
  const AddProgressEvent(this.goal, this.addedAmount);
  @override
  List<Object?> get props => [goal, addedAmount];
}

class DeleteGoalEvent extends GoalEvent {
  final String id;
  const DeleteGoalEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class GenerateGoalReportEvent extends GoalEvent {
  final GoalEntity goal;
  const GenerateGoalReportEvent(this.goal);
  @override
  List<Object?> get props => [goal];
}

class ClearGoalReportEvent extends GoalEvent {}

// Internal Events
class GoalsUpdatedEvent extends GoalEvent {
  final List<GoalEntity> goals;
  const GoalsUpdatedEvent(this.goals);
}

class GoalsErrorEvent extends GoalEvent {
  final String message;
  const GoalsErrorEvent(this.message);
}
