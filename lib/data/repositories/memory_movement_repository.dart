import '../../domain/models/financial_movement.dart';
import '../../domain/repositories/movement_repository.dart';

// Implementación temporal en memoria
// Sprint futuro: reemplazar por DriftMovementRepository
// o SupabaseMovementRepository sin tocar el ViewModel
class MemoryMovementRepository implements MovementRepository {
  final List<FinancialMovement> _movements = [];

  @override
  Future<void> save(FinancialMovement movement) async {
    _movements.add(movement);
  }

  @override
  Future<List<FinancialMovement>> getByMonth(int year, int month) async {
    return _movements.where((m) {
      return m.date.year == year && m.date.month == month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<FinancialMovement>> getRecent({int limit = 10}) async {
    final sorted = [..._movements]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  @override
  Future<void> delete(String id) async {
    _movements.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> clear() async {
    _movements.clear();
  }
}
