import 'dart:typed_data';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class AnalyzeReceiptUseCase {
  final AiRepository aiRepository;

  AnalyzeReceiptUseCase(this.aiRepository);

  Future<ExpenseEntity> call(Uint8List imageBytes, String mimeType) async {
    return await aiRepository.extractAndCategorizeExpenseFromImage(imageBytes, mimeType);
  }
}
