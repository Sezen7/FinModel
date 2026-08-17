import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/analyze_receipt_usecase.dart';
import '../../domain/entities/expense_entity.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;
  final AnalyzeReceiptUseCase analyzeReceiptUseCase;
  StreamSubscription? _expensesSubscription;

  ExpenseBloc({
    required this.expenseRepository,
    required this.analyzeReceiptUseCase,
  }) : super(ExpenseInitial()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<AnalyzeReceiptImageEvent>(_onAnalyzeReceiptImage);
    on<ClearAiAnalysisEvent>(_onClearAiAnalysis);
    on<_ExpensesUpdatedEvent>(_onExpensesUpdated);
    on<_ExpensesErrorEvent>(_onExpensesError);
  }

  void _onLoadExpenses(LoadExpensesEvent event, Emitter<ExpenseState> emit) {
    emit(ExpenseLoading());
    _expensesSubscription?.cancel();
    _expensesSubscription = expenseRepository.getExpenses(event.userId).listen(
      (expenses) {
        add(_ExpensesUpdatedEvent(expenses));
      },
      onError: (error) {
        add(_ExpensesErrorEvent(error.toString()));
      },
    );
  }

  Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.addExpense(event.expense);
      emit(const ExpenseActionSuccess('Harcama başarıyla eklendi.'));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.deleteExpense(event.id);
      emit(const ExpenseActionSuccess('Harcama silindi.'));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAnalyzeReceiptImage(AnalyzeReceiptImageEvent event, Emitter<ExpenseState> emit) async {
    emit(AiAnalysisLoading());
    try {
      final analyzedData = await analyzeReceiptUseCase(event.imageBytes, event.mimeType);
      emit(AiAnalysisSuccess(analyzedData));
    } catch (e) {
      emit(ExpenseError('Fiş analiz edilemedi: ${e.toString().replaceAll('Exception: ', '')}'));
    }
  }

  void _onClearAiAnalysis(ClearAiAnalysisEvent event, Emitter<ExpenseState> emit) {
    emit(ExpenseInitial());
  }

  // Internal events to handle stream output
  void _onExpensesUpdated(_ExpensesUpdatedEvent event, Emitter<ExpenseState> emit) {
    emit(ExpensesLoaded(event.expenses));
  }

  void _onExpensesError(_ExpensesErrorEvent event, Emitter<ExpenseState> emit) {
    emit(ExpenseError(event.message));
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }
}

class _ExpensesUpdatedEvent extends ExpenseEvent {
  final List<ExpenseEntity> expenses;
  const _ExpensesUpdatedEvent(this.expenses);
}

class _ExpensesErrorEvent extends ExpenseEvent {
  final String message;
  const _ExpensesErrorEvent(this.message);
}
