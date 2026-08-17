import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class LoadExpensesEvent extends ExpenseEvent {
  final String userId;
  const LoadExpensesEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AddExpenseEvent extends ExpenseEvent {
  final ExpenseEntity expense;
  const AddExpenseEvent(this.expense);
  @override
  List<Object?> get props => [expense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String id;
  const DeleteExpenseEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class AnalyzeReceiptImageEvent extends ExpenseEvent {
  final Uint8List imageBytes;
  final String mimeType;
  const AnalyzeReceiptImageEvent(this.imageBytes, this.mimeType);
  @override
  List<Object?> get props => [imageBytes, mimeType];
}

class ClearAiAnalysisEvent extends ExpenseEvent {}
