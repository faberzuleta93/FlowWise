import 'package:flutter/material.dart';
import '../state/auth_state_notifier.dart';
import '../state/financial_state_notifier.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../main.dart' show MainNavigator;
import 'startup_route_resolver.dart';

/// Único responsable del flujo principal de navegación.
///
/// Escucha AuthStateNotifier, consulta StartupRouteResolver y
/// representa la ruta resultante. Ninguna pantalla decide flujo:
/// "Las pantallas representan estados; no deciden estados."
class AppRoot extends StatelessWidget {
  final AuthStateNotifier authNotifier;
  final FinancialStateNotifier financialNotifier;

  const AppRoot({
    super.key,
    required this.authNotifier,
    required this.financialNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authNotifier,
      builder: (context, _) {
        final route = StartupRouteResolver.resolve(
          authStatus: authNotifier.status,
        );

        return switch (route) {
          StartupRoute.splash => const SplashScreen(),
          StartupRoute.welcome => const WelcomeScreen(),
          StartupRoute.home =>
            MainNavigator(financialNotifier: financialNotifier),
        };
      },
    );
  }
}
