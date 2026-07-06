import '../domain/models/financial_profile.dart';
import '../state/auth_state_notifier.dart';

/// Rutas posibles al arranque de FlowWise.
enum StartupRoute { splash, welcome, financialProfile, home }

/// Decide la primera ruta de la aplicación.
///
/// Función pura: recibe estados ya resueltos, retorna ruta.
/// No navega, no conoce widgets, no tiene efectos secundarios.
/// Si esta lógica deja de caber en una función pura, será el
/// momento de promoverla a un coordinador — no antes (Regla 1).
///
/// "Las pantallas representan estados; no deciden estados."
class StartupRouteResolver {
  const StartupRouteResolver._();

  static StartupRoute resolve({
    required AuthStatus authStatus,
    required OnboardingStatus onboardingStatus,
  }) {
    return switch (authStatus) {
      AuthStatus.unknown => StartupRoute.splash,
      AuthStatus.unauthenticated => StartupRoute.welcome,
      AuthStatus.authenticated => switch (onboardingStatus) {
          // Perfil aún cargando: la marca sigue en pantalla.
          OnboardingStatus.unknown => StartupRoute.splash,
          // Nunca se le ofreció: única vez que se muestra el flujo.
          OnboardingStatus.notOffered => StartupRoute.financialProfile,
          // Pospuesto o completado: nunca reinterrumpir.
          OnboardingStatus.offered ||
          OnboardingStatus.completed =>
            StartupRoute.home,
        },
    };
  }
}
