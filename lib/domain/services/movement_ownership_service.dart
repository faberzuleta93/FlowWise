import '../models/user_profile.dart';

/// Contrato del servicio de asociación de movimientos a un usuario.
///
/// Decisión arquitectónica (Sprint 3): FinancialMovement NO tiene
/// campo userId mientras FlowWise sea una app de un solo usuario
/// con persistencia local. Este servicio encapsula la asociación
/// de movimientos preexistentes a la cuenta que inicia sesión,
/// sin modificar el modelo de dominio ni sus mappers.
///
/// El dueño de un movimiento es el usuario de FlowWise (UserProfile),
/// nunca el identificador del proveedor de autenticación. Esto
/// permite cambiar de proveedor sin tocar este contrato.
///
/// Cuando llegue la sincronización remota, la propiedad pasará a
/// ser parte del modelo de forma natural y este servicio ejecutará
/// esa migración.
abstract class MovementOwnershipService {
  /// True si existen movimientos en el dispositivo que aún no
  /// pertenecen a ninguna cuenta. Determina si se debe mostrar
  /// el diálogo "¿Deseas conservar estos datos?" (Decisión 4).
  Future<bool> hasUnownedMovements();

  /// Asocia todos los movimientos sin dueño al usuario [owner].
  /// El usuario eligió "Conservar".
  Future<void> claimMovements({required UserProfile owner});

  /// Elimina todos los movimientos sin dueño.
  /// El usuario eligió "Empezar de cero".
  Future<void> discardUnownedMovements();
}
