import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/models/auth_session.dart';
import '../domain/repositories/authentication_repository.dart';

/// Estado de la sesión desde la perspectiva de la UI.
enum AuthStatus {
  /// Aún no sabemos si hay sesión (arranque). El Splash espera aquí.
  unknown,
  authenticated,
  unauthenticated,
}

/// Orquestador ligero de sesión.
///
/// Única responsabilidad: escuchar authStateChanges() y exponer
/// el estado actual. No conoce UserProfile, FinancialProfile,
/// navegación ni ningún proveedor concreto.
class AuthStateNotifier extends ChangeNotifier {
  final AuthenticationRepository _repository;
  StreamSubscription<AuthSession?>? _subscription;

  AuthStatus _status = AuthStatus.unknown;
  AuthSession? _session;

  AuthStateNotifier({required AuthenticationRepository repository})
      : _repository = repository {
    _subscription = _repository.authStateChanges().listen(_onSessionChanged);
  }

  AuthStatus get status => _status;

  /// Sesión activa. Null cuando status != authenticated.
  AuthSession? get session => _session;

  void _onSessionChanged(AuthSession? session) {
    _session = session;
    _status =
        session == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
