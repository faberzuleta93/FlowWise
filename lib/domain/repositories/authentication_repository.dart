import '../models/auth_session.dart';

/// Contrato de autenticación de FlowWise.
///
/// Responsabilidad única: administrar la SESIÓN del usuario.
/// No conoce perfiles, no conoce datos financieros, no conoce
/// ningún proveedor concreto (Firebase, Supabase, etc.).
/// Las implementaciones viven en la capa data/.
abstract class AuthenticationRepository {
  /// Emite la sesión actual cada vez que cambia el estado de
  /// autenticación. Emite null cuando no hay sesión activa.
  /// El Splash y el AuthStateNotifier escuchan este stream.
  Stream<AuthSession?> authStateChanges();

  /// Sesión activa en este momento. Null si no hay sesión.
  Future<AuthSession?> getCurrentSession();

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  });

  /// [name] se persiste en el proveedor y viajará en
  /// AuthSession.displayName, uniforme con Google/Apple.
  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  });

  Future<AuthSession> signInWithGoogle();

  Future<AuthSession> signInWithApple();

  Future<void> signOut();
}
