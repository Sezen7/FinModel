import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// E-posta ve şifre ile giriş yap
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// E-posta ve şifre ile kayıt ol
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String profession,
    required double estimatedIncome,
    required double estimatedExpense,
  });

  /// Google ile giriş yap
  Future<UserEntity> signInWithGoogle();

  /// Çıkış yap
  Future<void> signOut();

  /// Mevcut giriş yapmış kullanıcıyı döndür (null ise oturum yok)
  UserEntity? getCurrentUser();

  /// Şifre sıfırlama e-postası gönder
  Future<void> sendPasswordResetEmail(String email);

  /// Auth durum akışı (stream)
  Stream<UserEntity?> get authStateChanges;
}
