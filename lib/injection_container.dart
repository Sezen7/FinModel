import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_with_email_usecase.dart';
import 'features/auth/domain/usecases/register_with_email_usecase.dart';
import 'features/auth/domain/usecases/google_signin_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Expense
import 'features/expense_tracking/data/datasources/ai_remote_datasource.dart';
import 'features/expense_tracking/data/datasources/expense_remote_datasource.dart';
import 'features/expense_tracking/data/repositories/expense_repository_impl.dart';
import 'features/expense_tracking/domain/repositories/expense_repository.dart';
import 'features/expense_tracking/domain/usecases/analyze_receipt_usecase.dart';
import 'features/expense_tracking/presentation/bloc/expense_bloc.dart';

// Saving Goals
import 'features/saving_goals/data/datasources/goal_remote_datasource.dart';
import 'features/saving_goals/data/datasources/goal_ai_datasource.dart';
import 'features/saving_goals/data/repositories/goal_repository_impl.dart';
import 'features/saving_goals/domain/repositories/goal_repository.dart';
import 'features/saving_goals/domain/usecases/goal_usecases.dart';
import 'features/saving_goals/presentation/bloc/goal_bloc.dart';

// Robo Advisor
import 'features/robo_advisor/data/datasources/robo_advisor_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! ---- AUTH FEATURE ----
  sl.registerFactory(() => AuthBloc(
        loginWithEmail: sl(),
        registerWithEmail: sl(),
        signInWithGoogle: sl(),
        signOut: sl(),
        authRepository: sl(),
      ));

  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
        firebaseAuth: sl(),
        googleSignIn: sl(),
      ));

  //! ---- EXPENSE FEATURE ----
  sl.registerFactory(() => ExpenseBloc(
        expenseRepository: sl(),
        analyzeReceiptUseCase: sl(),
      ));

  sl.registerLazySingleton(() => AnalyzeReceiptUseCase(sl()));

  sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AiRepository>(() => AiRepositoryImpl(aiDataSource: sl()));

  sl.registerLazySingleton<ExpenseRemoteDataSource>(() => ExpenseRemoteDataSourceImpl(firestore: sl()));
  sl.registerLazySingleton<AiRemoteDataSource>(() => AiRemoteDataSourceImpl());

  //! ---- SAVING GOALS FEATURE ----
  sl.registerFactory(() => GoalBloc(
        goalRepository: sl(),
        addGoalUseCase: sl(),
        addProgressUseCase: sl(),
        generateReportUseCase: sl(),
      ));

  sl.registerLazySingleton(() => AddGoalUseCase(sl()));
  sl.registerLazySingleton(() => AddProgressUseCase(sl()));
  sl.registerLazySingleton(() => GenerateGoalReportUseCase(sl()));

  sl.registerLazySingleton<GoalRepository>(() => GoalRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<GoalAiRepository>(() => GoalAiRepositoryImpl(aiDataSource: sl()));

  sl.registerLazySingleton<GoalRemoteDataSource>(() => GoalRemoteDataSourceImpl(firestore: sl()));
  sl.registerLazySingleton<GoalAiDataSource>(() => GoalAiDataSourceImpl());

  //! ---- ROBO ADVISOR FEATURE ----
  sl.registerLazySingleton<RoboAdvisorDataSource>(() => RoboAdvisorDataSourceImpl());

  //! ---- EXTERNAL DEPENDENCIES ----
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
}
