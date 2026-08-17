import 'dart:typed_data';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    final model = ExpenseModel.fromEntity(expense);
    return await remoteDataSource.addExpense(model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    return await remoteDataSource.deleteExpense(id);
  }

  @override
  Stream<List<ExpenseEntity>> getExpenses(String userId) {
    return remoteDataSource.getExpenses(userId);
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    final model = ExpenseModel.fromEntity(expense);
    return await remoteDataSource.updateExpense(model);
  }
}

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource aiDataSource;

  AiRepositoryImpl({required this.aiDataSource});

  @override
  Future<ExpenseEntity> extractAndCategorizeExpenseFromImage(Uint8List imageBytes, String mimeType) async {
    return await aiDataSource.extractAndCategorizeExpenseFromImage(imageBytes, mimeType);
  }
}
