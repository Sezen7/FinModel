import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  LoginWithEmailEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String profession;
  final double estimatedIncome;
  final double estimatedExpense;

  RegisterWithEmailEvent({
    required this.email,
    required this.password,
    required this.displayName,
    required this.profession,
    required this.estimatedIncome,
    required this.estimatedExpense,
  });
  
  @override
  List<Object?> get props => [email, password, displayName, profession, estimatedIncome, estimatedExpense];
}

class SignInWithGoogleEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}

class AuthStateChangedEvent extends AuthEvent {
  final UserEntity? user;
  AuthStateChangedEvent({this.user});
  @override
  List<Object?> get props => [user];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  ForgotPasswordEvent({required this.email});
  @override
  List<Object?> get props => [email];
}

class DemoLoginEvent extends AuthEvent {}
