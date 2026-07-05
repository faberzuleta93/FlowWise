import '../models/financial_movement.dart';

/// Contrato abstracto para la persistencia de movimientos
/// financieros. El dominio depende únicamente de esta interfaz,
/// nunca de una implementación concreta.
abstract class MovementRepository {
  Future<void> save(FinancialMovement movement);
  Future<List<FinancialMovement>> getByMonth(int year, int month);
  Future<List<FinancialMovement>> getRecent({int limit = 10});
  Future<void> delete(String id);

  /// Elimina todos los movimientos.
  /// Usado en: cerrar sesión, eliminar cuenta.
  Future<void> clear();
}
