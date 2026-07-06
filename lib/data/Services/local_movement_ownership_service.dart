import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/services/movement_ownership_service.dart';
import '../datasources/movement_datasource.dart';

/// Implementación local de [MovementOwnershipService].
///
/// La propiedad se registra con una marca estable:
/// 'flowwise_movements_owner_uid' = UserProfile.id. La key está
/// diseñada para sobrevivir al cambio de implementación de
/// persistencia (mismo significado cuando exista Firestore).
class LocalMovementOwnershipService implements MovementOwnershipService {
  static const String _ownerKey = 'flowwise_movements_owner_uid';

  final MovementDatasource _movementDatasource;

  const LocalMovementOwnershipService({
    required MovementDatasource movementDatasource,
  }) : _movementDatasource = movementDatasource;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<bool> hasUnownedMovements() async {
    final prefs = await _prefs;
    if (prefs.getString(_ownerKey) != null) return false;
    final movements = await _movementDatasource.getAll();
    return movements.isNotEmpty;
  }

  @override
  Future<void> claimMovements({required UserProfile owner}) async {
    final prefs = await _prefs;
    await prefs.setString(_ownerKey, owner.id);
  }

  @override
  Future<void> discardUnownedMovements() async {
    await _movementDatasource.clear();
  }
}
