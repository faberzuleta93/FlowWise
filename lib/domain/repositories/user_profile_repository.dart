import '../models/user_profile.dart';

/// Contrato de persistencia de la identidad del usuario en FlowWise.
///
/// Responsabilidad única: administrar el UserProfile.
/// No contiene lógica de autenticación ni conoce datos financieros.
abstract class UserProfileRepository {
  /// Perfil del usuario actual. Null si aún no se ha creado.
  Future<UserProfile?> getCurrentProfile();

  /// Crea el perfil por primera vez.
  Future<void> save(UserProfile profile);

  /// Actualiza un perfil existente.
  ///
  /// Hoy la implementación local puede coincidir con [save], pero
  /// el dominio distingue ambas intenciones para no cambiar el
  /// contrato cuando exista persistencia remota.
  Future<void> update(UserProfile profile);

  Future<void> delete();
}
