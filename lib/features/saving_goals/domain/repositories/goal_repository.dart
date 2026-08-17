import '../entities/goal_entity.dart';

abstract class GoalRepository {
  Future<void> addGoal(GoalEntity goal);
  Future<void> updateGoal(GoalEntity goal);
  Future<void> deleteGoal(String id);
  Stream<List<GoalEntity>> getGoals(String userId);
}

abstract class GoalAiRepository {
  Future<String> generateProgressReport({
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime deadlineDate,
    required DateTime createdAt,
  });
}
