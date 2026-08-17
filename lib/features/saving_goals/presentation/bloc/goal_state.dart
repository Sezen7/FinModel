import 'package:equatable/equatable.dart';
import '../../domain/entities/goal_entity.dart';

abstract class GoalState extends Equatable {
  const GoalState();
  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {}

class GoalLoading extends GoalState {}

class GoalsLoaded extends GoalState {
  final List<GoalEntity> goals;
  const GoalsLoaded(this.goals);
  @override
  List<Object?> get props => [goals];
}

class GoalError extends GoalState {
  final String message;
  const GoalError(this.message);
  @override
  List<Object?> get props => [message];
}

class GoalActionSuccess extends GoalState {
  final String message;
  const GoalActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class GoalReportLoading extends GoalState {}

class GoalReportSuccess extends GoalState {
  final String report;
  const GoalReportSuccess(this.report);
  @override
  List<Object?> get props => [report];
}
