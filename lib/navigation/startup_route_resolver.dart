import '../domain/models/financial_profile.dart';
import '../state/auth_state_notifier.dart';
import '../state/movement_ownership_notifier.dart';

/// Rutas posibles al arranque de FlowWise.
enum StartupRoute { splash, welcome, ownershipDecision, financialProfile, home }

/// Decide la primera ruta de la aplicación.
///
/// Función pura: recibe estados ya resueltos, retorna ruta.
/// Secuencia de negocio: Auth → Ownership → Onboarding → Home.
///
/// UMBRAL DOCUMENTADO: hoy combina exactamente tres estados
/// independientes sin lógica secuencial. Cuando necesite más de
/// tres, o ejecutar lógica secuencial entre ellos, se promueve
/// a StartupCoordinator (criterio objetivo, ADR-0001).
///
/// "Las pantallas representan estados; no deciden estados."
class StartupRouteResolver {
  const StartupRouteResolver._();

  static StartupRoute resolve({
    required AuthStatus authStatus,
    required OwnershipStatus ownershipStatus,
    required OnboardingStatus onboardingStatus,
  }) {
    return switch (authStatus) {
      AuthStatus.unknown => StartupRoute.splash,
      AuthStatus.unauthenticated => StartupRoute.welcome,
      AuthStatus.authenticated => switch (ownershipStatus) {
          OwnershipStatus.unknown => StartupRoute.splash,
          OwnershipStatus.pending => StartupRoute.ownershipDecision,
          OwnershipStatus.resolved => switch (onboardingStatus) {
              OnboardingStatus.unknown => StartupRoute.splash,
              OnboardingStatus.notOffered => StartupRoute.financialProfile,
              OnboardingStatus.offered ||
              OnboardingStatus.completed =>
                StartupRoute.home,
            },
        },
    };
  }
}
