import '../../../../core/usecases/usecase.dart';
import '../entities/goal_entity.dart';
import '../repositories/goal_repository.dart';

class AddGoalUseCase implements UseCase<void, GoalEntity> {
  final GoalRepository repository;

  AddGoalUseCase(this.repository);

  @override
  Future<void> call(GoalEntity params) async {
    return await repository.addGoal(params);
  }
}

class AddProgressUseCase implements UseCase<void, ProgressParams> {
  final GoalRepository repository;

  AddProgressUseCase(this.repository);

  @override
  Future<void> call(ProgressParams params) async {
    final newAmount = params.goal.currentAmount + params.addedAmount;
    final isCompleted = newAmount >= params.goal.targetAmount;
    
    final updatedHistory = List<double>.from(params.goal.progressHistory);
    updatedHistory.add(newAmount);

    final updatedGoal = GoalEntity(
      id: params.goal.id,
      userId: params.goal.userId,
      title: params.goal.title,
      targetAmount: params.goal.targetAmount,
      currentAmount: newAmount,
      deadlineDate: params.goal.deadlineDate,
      createdAt: params.goal.createdAt,
      colorHex: params.goal.colorHex,
      monthlyContribution: params.goal.monthlyContribution,
      durationMonths: params.goal.durationMonths,
      progressHistory: updatedHistory,
      isCompleted: isCompleted,
      completionDate: isCompleted ? DateTime.now() : params.goal.completionDate,
    );
    return await repository.updateGoal(updatedGoal);
  }
}

class ProgressParams {
  final GoalEntity goal;
  final double addedAmount;

  ProgressParams({required this.goal, required this.addedAmount});
}

class GenerateGoalReportUseCase implements UseCase<String, GoalEntity> {
  final GoalAiRepository aiRepository;

  GenerateGoalReportUseCase(this.aiRepository);

  @override
  Future<String> call(GoalEntity goal) async {
    return await aiRepository.generateProgressReport(
      title: goal.title,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      deadlineDate: goal.deadlineDate,
      createdAt: goal.createdAt,
    );
  }
}
