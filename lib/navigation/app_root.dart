import 'package:flutter/material.dart';
import '../domain/repositories/authentication_repository.dart';
import '../state/auth_state_notifier.dart';
import '../state/financial_profile_notifier.dart';
import '../state/financial_state_notifier.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/financial_profile/financial_profile_screen.dart';
import '../main.dart' show MainNavigator;
import 'startup_route_resolver.dart';

/// Único responsable del flujo principal de navegación.
///
/// Escucha AuthStateNotifier y FinancialProfileNotifier, consulta
/// StartupRouteResolver y representa la ruta resultante. Cuando el
/// estado de flujo cambia, limpia cualquier pantalla apilada.
/// "Las pantallas representan estados; no deciden estados."
class AppRoot extends StatefulWidget {
  final AuthStateNotifier authNotifier;
  final FinancialStateNotifier financialNotifier;
  final FinancialProfileNotifier profileNotifier;
  final AuthenticationRepository authRepository;

  const AppRoot({
    super.key,
    required this.authNotifier,
    required this.financialNotifier,
    required this.profileNotifier,
    required this.authRepository,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    widget.authNotifier.addListener(_onAuthChanged);
    _loadProfileIfAuthenticated();
  }

  @override
  void dispose() {
    widget.authNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    // Regla 5: al cambiar el flujo, ninguna pantalla apilada
    // puede quedar tapando el nuevo estado.
    Navigator.of(context).popUntil((route) => route.isFirst);
    _loadProfileIfAuthenticated();
  }

  /// Dispara la carga del perfil al autenticarse.
  /// load() es idempotente, por lo que llamarla varias veces es seguro.
  void _loadProfileIfAuthenticated() {
    if (widget.authNotifier.status == AuthStatus.authenticated) {
      widget.profileNotifier.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable:
          Listenable.merge([widget.authNotifier, widget.profileNotifier]),
      builder: (context, _) {
        final route = StartupRouteResolver.resolve(
          authStatus: widget.authNotifier.status,
          onboardingStatus: widget.profileNotifier.onboardingStatus,
        );

        return switch (route) {
          StartupRoute.splash => const SplashScreen(),
          StartupRoute.welcome =>
            WelcomeScreen(authRepository: widget.authRepository),
          StartupRoute.financialProfile => FinancialProfileScreen(
              profileNotifier: widget.profileNotifier,
            ),
          StartupRoute.home => MainNavigator(
              financialNotifier: widget.financialNotifier,
              profileNotifier: widget.profileNotifier,
              authRepository: widget.authRepository,
            ),
        };
      },
    );
  }
}
