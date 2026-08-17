import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String profession,
    required double estimatedIncome,
    required double estimatedExpense,
  }) async {
    return await remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      profession: profession,
      estimatedIncome: estimatedIncome,
      estimatedExpense: estimatedExpense,
    );
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  UserEntity? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return await remoteDataSource.sendPasswordResetEmail(email);
  }
}
