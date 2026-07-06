import 'package:flutter/material.dart';
import '../domain/repositories/authentication_repository.dart';
import '../state/auth_state_notifier.dart';
import '../state/financial_profile_notifier.dart';
import '../state/financial_state_notifier.dart';
import '../state/movement_ownership_notifier.dart';
import '../state/user_profile_notifier.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/ownership/ownership_decision_screen.dart';
import '../screens/financial_profile/financial_profile_screen.dart';
import '../main.dart' show MainNavigator;
import 'startup_route_resolver.dart';

/// Único responsable del flujo principal de navegación.
/// "Las pantallas representan estados; no deciden estados."
class AppRoot extends StatefulWidget {
  final AuthStateNotifier authNotifier;
  final FinancialStateNotifier financialNotifier;
  final FinancialProfileNotifier profileNotifier;
  final UserProfileNotifier userProfileNotifier;
  final MovementOwnershipNotifier ownershipNotifier;
  final AuthenticationRepository authRepository;

  const AppRoot({
    super.key,
    required this.authNotifier,
    required this.financialNotifier,
    required this.profileNotifier,
    required this.userProfileNotifier,
    required this.ownershipNotifier,
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
    _prepareAuthenticatedState();
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

    if (widget.authNotifier.status == AuthStatus.unauthenticated) {
      // Limpieza de estado en memoria al cerrar sesión.
      widget.userProfileNotifier.clear();
      widget.ownershipNotifier.reset();
    }
    _prepareAuthenticatedState();
  }

  /// Secuencia post-autenticación: sembrar identidad y resolver
  /// propiedad de movimientos. Ambas operaciones son idempotentes.
  Future<void> _prepareAuthenticatedState() async {
    if (widget.authNotifier.status != AuthStatus.authenticated) return;
    final session = widget.authNotifier.session;
    if (session == null) return;

    await widget.userProfileNotifier.loadFrom(session);
    final owner = widget.userProfileNotifier.profile;
    if (owner != null) {
      await widget.ownershipNotifier.resolveFor(owner);
    }
    widget.profileNotifier.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.authNotifier,
        widget.userProfileNotifier,
        widget.ownershipNotifier,
        widget.profileNotifier,
      ]),
      builder: (context, _) {
        final route = StartupRouteResolver.resolve(
          authStatus: widget.authNotifier.status,
          ownershipStatus: widget.ownershipNotifier.status,
          onboardingStatus: widget.profileNotifier.onboardingStatus,
        );

        return switch (route) {
          StartupRoute.splash => const SplashScreen(),
          StartupRoute.welcome =>
            WelcomeScreen(authRepository: widget.authRepository),
          StartupRoute.ownershipDecision => OwnershipDecisionScreen(
              ownershipNotifier: widget.ownershipNotifier,
              userProfileNotifier: widget.userProfileNotifier,
            ),
          StartupRoute.financialProfile => FinancialProfileScreen(
              profileNotifier: widget.profileNotifier,
            ),
          StartupRoute.home => MainNavigator(
              financialNotifier: widget.financialNotifier,
              profileNotifier: widget.profileNotifier,
              userProfileNotifier: widget.userProfileNotifier,
              authRepository: widget.authRepository,
            ),
        };
      },
    );
  }
}
