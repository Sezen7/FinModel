import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> signUpWithEmail({
    required String email, 
    required String password, 
    required String displayName,
    required String profession,
    required double estimatedIncome,
    required double estimatedExpense,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  UserModel? getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String profession,
    required double estimatedIncome,
    required double estimatedExpense,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) throw FirebaseAuthException(code: 'user-not-found');

      // Save user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(updatedUser.uid).set({
        'uid': updatedUser.uid,
        'email': email,
        'displayName': displayName,
        'profession': profession,
        'estimatedIncome': estimatedIncome,
        'estimatedExpense': estimatedExpense,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserModel.fromFirebaseUser(updatedUser);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in iptal edildi.');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) throw FirebaseAuthException(code: 'user-not-found');
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
      (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  Exception _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Bu e-posta ile kayıtlı kullanıcı bulunamadı.');
      case 'wrong-password':
        return Exception('Hatalı şifre girdiniz.');
      case 'email-already-in-use':
        return Exception('Bu e-posta adresi zaten kullanımda.');
      case 'weak-password':
        return Exception('Şifre en az 6 karakter olmalıdır.');
      case 'invalid-email':
        return Exception('Geçersiz e-posta adresi.');
      case 'operation-not-allowed':
        return Exception('Firebase üzerinden Email/Şifre girişi aktif değil. Lütfen Console\'dan açın.');
      case 'too-many-requests':
        return Exception('Çok fazla başarısız deneme. Lütfen bekleyin.');
      default:
        return Exception(e.message ?? 'Kimlik doğrulama hatası oluştu.');
    }
  }
}
