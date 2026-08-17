import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmailUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  RegisterWithEmailUseCase(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      profession: params.profession,
      estimatedIncome: params.estimatedIncome,
      estimatedExpense: params.estimatedExpense,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final String profession;
  final double estimatedIncome;
  final double estimatedExpense;

  const RegisterParams({
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
