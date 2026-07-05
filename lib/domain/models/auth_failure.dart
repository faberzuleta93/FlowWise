/// Razones de fallo de autenticación que el dominio entiende.
/// La UI decide qué mensaje mostrar para cada una.
enum AuthFailureReason {
  invalidCredentials, // email o contraseña incorrectos
  emailAlreadyInUse, // registro con email ya existente
  weakPassword, // contraseña insegura
  invalidEmail, // formato de email inválido
  networkError, // sin conexión
  cancelled, // el usuario cerró el flujo (Google/Apple)
  unknown,
}

/// Error de autenticación expresado en términos del dominio.
/// Ningún consumidor necesita conocer el proveedor para manejarlo.
class AuthFailure implements Exception {
  final AuthFailureReason reason;
  const AuthFailure(this.reason);
}
