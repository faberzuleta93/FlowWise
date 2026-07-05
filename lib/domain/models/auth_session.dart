/// Sesión de autenticación activa.
///
/// Representa lo que el PROVEEDOR de autenticación (Firebase, y en el
/// futuro cualquier otro) sabe del usuario tras un login exitoso.
/// No es la identidad del usuario en FlowWise (ver UserProfile):
/// es la semilla desde la cual esa identidad se crea.
class AuthSession {
  /// Identificador único otorgado por el proveedor de autenticación.
  final String uid;

  final String email;

  /// Nombre entregado por el proveedor (Google/Apple lo incluyen,
  /// email/contraseña no). Null → se pedirá en el perfil.
  final String? displayName;

  /// Foto entregada por el proveedor. Null → se usará la inicial.
  final String? photoUrl;

  const AuthSession({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
