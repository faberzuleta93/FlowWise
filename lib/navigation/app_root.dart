import 'package:flutter/material.dart';
import '../domain/repositories/authentication_repository.dart';
import '../state/auth_state_notifier.dart';
import '../state/financial_state_notifier.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../main.dart' show MainNavigator;
import 'startup_route_resolver.dart';

/// Único responsable del flujo principal de navegación.
///
/// Escucha AuthStateNotifier, consulta StartupRouteResolver y
/// representa la ruta resultante. Además, cuando el estado de
/// flujo cambia, limpia cualquier pantalla apilada (ej. AuthScreen
/// pusheada sobre Welcome) para que el nuevo estado sea visible.
/// "Las pantallas representan estados; no deciden estados."
class AppRoot extends StatefulWidget {
  final AuthStateNotifier authNotifier;
  final FinancialStateNotifier financialNotifier;
  final AuthenticationRepository authRepository;

  const AppRoot({
    super.key,
    required this.authNotifier,
    required this.financialNotifier,
    required this.authRepository,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    widget.authNotifier.addListener(_onFlowStateChanged);
  }

  @override
  void dispose() {
    widget.authNotifier.removeListener(_onFlowStateChanged);
    super.dispose();
  }

  /// Al cambiar el estado de autenticación, desmonta cualquier
  /// pantalla apilada sobre la raíz (Regla 5: solo AppRoot decide
  /// el flujo principal; ninguna pantalla se queda tapándolo).
  void _onFlowStateChanged() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authNotifier,
      builder: (context, _) {
        final route = StartupRouteResolver.resolve(
          authStatus: widget.authNotifier.status,
        );

        return switch (route) {
          StartupRoute.splash => const SplashScreen(),
          StartupRoute.welcome =>
            WelcomeScreen(authRepository: widget.authRepository),
          StartupRoute.home => MainNavigator(
              financialNotifier: widget.financialNotifier,
              authRepository: widget.authRepository,
            ),
        };
      },
    );
  }
}
