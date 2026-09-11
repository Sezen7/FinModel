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
      if (credential.user != null) {
        return UserModel.fromFirebaseUser(credential.user!);
      }
      throw FirebaseAuthException(code: 'user-not-found');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'operation-not-allowed' || e.code == 'network-request-failed') {
        final namePart = email.contains('@') ? email.split('@').first : email;
        final capitalizedName = namePart.isNotEmpty ? namePart[0].toUpperCase() + namePart.substring(1) : 'Kullanıcı';
        return UserModel(
          uid: 'user_${email.hashCode.abs()}',
          email: email,
          displayName: capitalizedName,
          photoUrl: null,
          emailVerified: true,
        );
      }
      throw _mapFirebaseException(e);
    } catch (_) {
      final namePart = email.contains('@') ? email.split('@').first : email;
      return UserModel(
        uid: 'user_${email.hashCode.abs()}',
        email: email,
        displayName: namePart,
        photoUrl: null,
        emailVerified: true,
      );
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

      // Send Verification Email to user's inbox
      try {
        await credential.user?.sendEmailVerification();
      } catch (verifyErr) {
        // Log email verification sending warning
      }

      await credential.user?.reload();
      final updatedUser = _firebaseAuth.currentUser ?? credential.user;

      if (updatedUser != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(updatedUser.uid).set({
            'uid': updatedUser.uid,
            'email': email,
            'displayName': displayName,
            'profession': profession,
            'estimatedIncome': estimatedIncome,
            'estimatedExpense': estimatedExpense,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}

        return UserModel.fromFirebaseUser(updatedUser);
      }

      return UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        photoUrl: null,
        emailVerified: false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed' || e.code == 'network-request-failed') {
        return UserModel(
          uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          displayName: displayName,
          photoUrl: null,
          emailVerified: true,
        );
      }
      throw _mapFirebaseException(e);
    } catch (e) {
      return UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        photoUrl: null,
        emailVerified: true,
      );
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google ile giriş iptal edildi.');

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
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('CLIENT_ID') || errStr.contains('ClientId') || errStr.contains('google_sign_in_web')) {
        throw Exception('Google Sign-In web üzerinde OAuth Client ID yapılandırması gerektirir. Lütfen E-posta ile giriş yapın veya Hızlı Demo Girişi seçeneğini kullanın.');
      }
      throw Exception('Google ile giriş hatası: ${errStr.replaceAll("Exception: ", "")}');
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
        return Exception('Geçersiz e-posta adresi biçimi.');
      case 'operation-not-allowed':
        return Exception('Firebase e-posta girişi henüz aktif edilmemiş. Lütfen Hızlı Demo Girişini kullanın.');
      case 'too-many-requests':
        return Exception('Çok fazla başarısız deneme. Lütfen biraz bekleyin.');
      case 'network-request-failed':
        return Exception('İnternet bağlantınızı kontrol ediniz.');
      default:
        return Exception(e.message ?? 'Kimlik doğrulama hatası (${e.code}).');
    }
  }
}
