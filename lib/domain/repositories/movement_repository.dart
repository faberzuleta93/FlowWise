import '../models/financial_movement.dart';

// Contrato abstracto — no sabe si los datos van a memoria,
// SQLite, Drift o Supabase. El ViewModel solo conoce esta interfaz.
abstract class MovementRepository {
  Future<void> save(FinancialMovement movement);
  Future<List<FinancialMovement>> getByMonth(int year, int month);
  Future<List<FinancialMovement>> getRecent({int limit = 10});
  Future<void> delete(String id);
  // Preparado para: sincronización, filtros, paginación
}
