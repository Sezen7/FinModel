import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/usecases/goal_usecases.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository goalRepository;
  final AddGoalUseCase addGoalUseCase;
  final AddProgressUseCase addProgressUseCase;
  final GenerateGoalReportUseCase generateReportUseCase;

  StreamSubscription? _goalsSubscription;

  GoalBloc({
    required this.goalRepository,
    required this.addGoalUseCase,
    required this.addProgressUseCase,
    required this.generateReportUseCase,
  }) : super(GoalInitial()) {
    on<LoadGoalsEvent>(_onLoadGoals);
    on<AddGoalSubmitEvent>(_onAddGoal);
    on<AddProgressEvent>(_onAddProgress);
    on<DeleteGoalEvent>(_onDeleteGoal);
    on<GenerateGoalReportEvent>(_onGenerateGoalReport);
    on<ClearGoalReportEvent>(_onClearResult);

    on<GoalsUpdatedEvent>(_onGoalsUpdated);
    on<GoalsErrorEvent>(_onGoalsError);
  }

  void _onLoadGoals(LoadGoalsEvent event, Emitter<GoalState> emit) {
    emit(GoalLoading());
    _goalsSubscription?.cancel();
    _goalsSubscription = goalRepository.getGoals(event.userId).listen(
      (goals) {
        add(GoalsUpdatedEvent(goals));
      },
      onError: (error) {
        add(GoalsErrorEvent(error.toString()));
      },
    );
  }

  Future<void> _onAddGoal(AddGoalSubmitEvent event, Emitter<GoalState> emit) async {
    try {
      await addGoalUseCase(event.goal);
      emit(const GoalActionSuccess('Hedef başarıyla oluşturuldu!'));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onAddProgress(AddProgressEvent event, Emitter<GoalState> emit) async {
    try {
      final double availableToTarget = event.goal.targetAmount - event.goal.currentAmount;
      final addAmountSafe = event.addedAmount > availableToTarget 
          ? availableToTarget 
          : event.addedAmount; // Don't allow depositing more than target
          
      await addProgressUseCase(ProgressParams(goal: event.goal, addedAmount: addAmountSafe));
      emit(const GoalActionSuccess('Kumbara başarıyla güncellendi!'));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onDeleteGoal(DeleteGoalEvent event, Emitter<GoalState> emit) async {
    try {
      await goalRepository.deleteGoal(event.id);
      emit(const GoalActionSuccess('Hedef silindi.'));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onGenerateGoalReport(GenerateGoalReportEvent event, Emitter<GoalState> emit) async {
    emit(GoalReportLoading());
    try {
      final report = await generateReportUseCase(event.goal);
      emit(GoalReportSuccess(report));
    } catch (e) {
      emit(GoalError('Rapor alınırken hata oluştu: $e'));
    }
  }

  void _onClearResult(ClearGoalReportEvent event, Emitter<GoalState> emit) {
    emit(GoalInitial()); // Clear ui
  }

  void _onGoalsUpdated(GoalsUpdatedEvent event, Emitter<GoalState> emit) {
    emit(GoalsLoaded(event.goals));
  }

  void _onGoalsError(GoalsErrorEvent event, Emitter<GoalState> emit) {
    emit(GoalError(event.message));
  }

  @override
  Future<void> close() {
    _goalsSubscription?.cancel();
    return super.close();
  }
}
