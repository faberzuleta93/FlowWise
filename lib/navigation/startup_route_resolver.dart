import '../state/auth_state_notifier.dart';

/// Rutas posibles al arranque de FlowWise.
enum StartupRoute { splash, welcome, home }

/// Decide la primera ruta de la aplicación.
///
/// Función pura: recibe estado, retorna ruta. No navega, no conoce
/// widgets, no tiene efectos secundarios. Es la semilla del futuro
/// coordinador de arranque: cuando el flujo crezca (premium,
/// verificación de email, mantenimiento, migraciones), crece aquí
/// — nunca en el Splash.
///
/// Principio de navegación de FlowWise:
/// "Las pantallas representan estados; no deciden estados."
class StartupRouteResolver {
  const StartupRouteResolver._();

  static StartupRoute resolve({
    required AuthStatus authStatus,
    bool hasCompletedFinancialProfile = false,
    // ↑ Vertical 4 lo conectará; hoy no altera la decisión.
  }) {
    return switch (authStatus) {
      AuthStatus.unknown => StartupRoute.splash,
      AuthStatus.unauthenticated => StartupRoute.welcome,
      AuthStatus.authenticated => StartupRoute.home,
    };
  }
}
