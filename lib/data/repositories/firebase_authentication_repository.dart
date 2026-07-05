import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/models/auth_failure.dart';
import '../../domain/repositories/authentication_repository.dart';

/// Implementación de [AuthenticationRepository] sobre Firebase Auth.
///
/// Regla 2 de arquitectura: este es el ÚNICO archivo del proyecto
/// autorizado a importar firebase_auth y google_sign_in.
/// Traduce User (Firebase) → AuthSession (dominio) y
/// FirebaseAuthException → AuthFailure (dominio).
class FirebaseAuthenticationRepository implements AuthenticationRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthenticationRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AuthSession?> authStateChanges() {
    return _auth.authStateChanges().map(_toSession);
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    return _toSession(_auth.currentUser);
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireSession(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireSession(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<AuthSession> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario cerró el selector de cuentas.
        throw const AuthFailure(AuthFailureReason.cancelled);
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return _requireSession(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<AuthSession> signInWithApple() async {
    // Pendiente: requiere cuenta Apple Developer activa.
    // El contrato del dominio ya lo soporta; se implementará
    // cuando la capability esté disponible.
    throw const AuthFailure(AuthFailureReason.unknown);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Traducción Firebase → Dominio ─────────────────────

  AuthSession? _toSession(User? user) {
    if (user == null) return null;
    return AuthSession(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  AuthSession _requireSession(User? user) {
    final session = _toSession(user);
    if (session == null) {
      throw const AuthFailure(AuthFailureReason.unknown);
    }
    return session;
  }

  AuthFailure _toFailure(FirebaseAuthException e) {
    return AuthFailure(switch (e.code) {
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        AuthFailureReason.invalidCredentials,
      'email-already-in-use' => AuthFailureReason.emailAlreadyInUse,
      'weak-password' => AuthFailureReason.weakPassword,
      'invalid-email' => AuthFailureReason.invalidEmail,
      'network-request-failed' => AuthFailureReason.networkError,
      _ => AuthFailureReason.unknown,
    });
  }
}
