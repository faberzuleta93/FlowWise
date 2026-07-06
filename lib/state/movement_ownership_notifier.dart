import 'package:flutter/foundation.dart';
import '../domain/models/user_profile.dart';
import '../domain/services/movement_ownership_service.dart';

/// Estado de la propiedad de los movimientos locales (Decisión 4).
enum OwnershipStatus {
  /// Aún no se ha verificado.
  unknown,

  /// Hay movimientos sin dueño: el usuario debe decidir.
  pending,

  /// Resuelto: reclamados, descartados, o no había nada que decidir.
  resolved,
}

/// Responsabilidad única: la propiedad de datos locales heredados.
/// Separado de UserProfileNotifier: identidad y datos heredados
/// son conceptos distintos (Regla 1).
class MovementOwnershipNotifier extends ChangeNotifier {
  final MovementOwnershipService _service;

  OwnershipStatus _status = OwnershipStatus.unknown;
  bool _checking = false;

  MovementOwnershipNotifier({required MovementOwnershipService service})
      : _service = service;

  OwnershipStatus get status => _status;

  /// Verifica la propiedad para el usuario [owner].
  ///
  /// Si no hay movimientos sin dueño, auto-reclama: escribe el
  /// uid del usuario para que sus propios movimientos futuros
  /// jamás disparen el diálogo en un próximo login.
  Future<void> resolveFor(UserProfile owner) async {
    if (_checking || _status != OwnershipStatus.unknown) return;
    _checking = true;

    final hasUnowned = await _service.hasUnownedMovements();
    if (hasUnowned) {
      _status = OwnershipStatus.pending;
    } else {
      await _service.claimMovements(owner: owner);
      _status = OwnershipStatus.resolved;
    }

    _checking = false;
    notifyListeners();
  }

  /// El usuario eligió "Conservarlos".
  Future<void> claim(UserProfile owner) async {
    await _service.claimMovements(owner: owner);
    _status = OwnershipStatus.resolved;
    notifyListeners();
  }

  /// El usuario eligió "Empezar desde cero".
  Future<void> discard(UserProfile owner) async {
    await _service.discardUnownedMovements();
    await _service.claimMovements(owner: owner);
    _status = OwnershipStatus.resolved;
    notifyListeners();
  }

  /// Reinicia el estado al cerrar sesión.
  void reset() {
    _status = OwnershipStatus.unknown;
    _checking = false;
    notifyListeners();
  }
}
