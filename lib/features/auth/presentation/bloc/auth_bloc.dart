import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/register_with_email_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/usecases/usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmailUseCase loginWithEmail;
  final RegisterWithEmailUseCase registerWithEmail;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SignOutUseCase signOut;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginWithEmail,
    required this.registerWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<AuthStateChangedEvent>(_onAuthStateChanged);
    on<DemoLoginEvent>(_onDemoLogin);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await loginWithEmail(
        LoginParams(email: event.email, password: event.password),
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await registerWithEmail(
        RegisterParams(
          email: event.email,
          password: event.password,
          displayName: event.displayName,
          profession: event.profession,
          estimatedIncome: event.estimatedIncome,
          estimatedExpense: event.estimatedExpense,
        ),
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogle(const NoParams());
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await signOut(const NoParams());
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.sendPasswordResetEmail(event.email);
      emit(ForgotPasswordSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onAuthStateChanged(
    AuthStateChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(Authenticated(user: event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onDemoLogin(
    DemoLoginEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(Authenticated(
      user: UserModel(
        uid: 'demo_user_123',
        email: 'demo@finmodel.com',
        displayName: 'Demo Kullanıcı',
        emailVerified: true,
      ),
    ));
  }
}
