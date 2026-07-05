import '../../domain/models/financial_movement.dart';
import '../../domain/repositories/movement_repository.dart';
import '../datasources/movement_datasource.dart';
import '../mappers/financial_movement_mapper.dart';

/// Implementación persistente de [MovementRepository].
///
/// Traduce entre el dominio ([FinancialMovement]) y el formato
/// de persistencia (Map) usando [FinancialMovementMapper], y
/// delega el almacenamiento crudo a [MovementDatasource].
///
/// La lógica de consulta (filtrar por mes, limitar resultados)
/// vive aquí, no en el datasource.
class LocalMovementRepository implements MovementRepository {
  final MovementDatasource _datasource;

  const LocalMovementRepository({
    required MovementDatasource datasource,
  }) : _datasource = datasource;

  @override
  Future<void> save(FinancialMovement movement) async {
    final data = FinancialMovementMapper.toMap(movement);
    await _datasource.save(data);
  }

  @override
  Future<List<FinancialMovement>> getByMonth(int year, int month) async {
    final all = await _getAllMovements();
    return all
        .where((m) => m.date.year == year && m.date.month == month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<FinancialMovement>> getRecent({int limit = 10}) async {
    final all = await _getAllMovements();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }

  @override
  Future<void> delete(String id) => _datasource.delete(id);

  @override
  Future<void> clear() => _datasource.clear();

  Future<List<FinancialMovement>> _getAllMovements() async {
    final rawList = await _datasource.getAll();
    return rawList.map((map) => FinancialMovementMapper.fromMap(map)).toList();
  }
}
