import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpensesLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;
  const ExpensesLoaded(this.expenses);
  @override
  List<Object?> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
  @override
  List<Object?> get props => [message];
}

class AiAnalysisLoading extends ExpenseState {}

class AiAnalysisSuccess extends ExpenseState {
  final ExpenseEntity analyzedData;
  const AiAnalysisSuccess(this.analyzedData);
  @override
  List<Object?> get props => [analyzedData];
}

class ExpenseActionSuccess extends ExpenseState {
  final String message;
  const ExpenseActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
