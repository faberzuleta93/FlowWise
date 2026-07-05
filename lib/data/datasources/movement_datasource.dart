/// Contrato abstracto para el almacenamiento crudo de movimientos.
///
/// Esta interfaz trabaja únicamente con representaciones ya
/// serializadas (Map). No conoce el modelo FinancialMovement
/// del dominio — esa traducción es responsabilidad exclusiva de
/// FinancialMovementMapper.
///
/// Implementaciones actuales: SharedPreferencesMovementDatasource
/// Implementaciones futuras: FirestoreMovementDatasource,
/// SupabaseMovementDatasource.
abstract class MovementDatasource {
  /// Guarda un movimiento ya serializado como Map.
  Future<void> save(Map<String, dynamic> movementData);

  /// Retorna todos los movimientos serializados como Map.
  /// El filtrado por mes o límite de cantidad se realiza
  /// en el repositorio, no en el datasource.
  Future<List<Map<String, dynamic>>> getAll();

  /// Elimina un movimiento por su ID.
  Future<void> delete(String id);

  /// Elimina todos los movimientos almacenados.
  Future<void> clear();
}
