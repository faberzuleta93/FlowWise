import '../models/financial_profile.dart';

/// Contrato de persistencia del perfil financiero inicial.
///
/// Responsabilidad única: administrar el FinancialProfile.
/// No conoce autenticación ni movimientos.
abstract class FinancialProfileRepository {
  /// Perfil financiero del usuario actual. Null si aún no existe.
  Future<FinancialProfile?> getCurrentProfile();

  /// Crea el perfil financiero por primera vez.
  Future<void> save(FinancialProfile profile);

  /// Actualiza un perfil financiero existente.
  Future<void> update(FinancialProfile profile);

  Future<void> delete();
}
