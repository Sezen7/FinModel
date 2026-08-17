import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_ai_datasource.dart';
import '../datasources/goal_remote_datasource.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource remoteDataSource;

  GoalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addGoal(GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    return await remoteDataSource.addGoal(model);
  }

  @override
  Future<void> deleteGoal(String id) async {
    return await remoteDataSource.deleteGoal(id);
  }

  @override
  Stream<List<GoalEntity>> getGoals(String userId) {
    return remoteDataSource.getGoals(userId);
  }

  @override
  Future<void> updateGoal(GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    return await remoteDataSource.updateGoal(model);
  }
}

class GoalAiRepositoryImpl implements GoalAiRepository {
  final GoalAiDataSource aiDataSource;

  GoalAiRepositoryImpl({required this.aiDataSource});

  @override
  Future<String> generateProgressReport({
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime deadlineDate,
    required DateTime createdAt,
  }) async {
    return await aiDataSource.generateProgressReport(
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadlineDate: deadlineDate,
      createdAt: createdAt,
    );
  }
}
