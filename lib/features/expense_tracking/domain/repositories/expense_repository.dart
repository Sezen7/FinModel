import 'dart:typed_data';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(ExpenseEntity expense);
  Stream<List<ExpenseEntity>> getExpenses(String userId);
}

abstract class AiRepository {
  /// Eklenen resimden OCR metin çıkartıp Gemini'ye gönderir, yapısal ExpenseEntity döner.
  Future<ExpenseEntity> extractAndCategorizeExpenseFromImage(Uint8List imageBytes, String mimeType);
}
