import 'package:flutter/foundation.dart';
import '../../domain/models/auth_failure.dart';
import '../../domain/repositories/authentication_repository.dart';

enum AuthFormMode { login, register }

enum AuthFormStatus { idle, loading, error }

/// Proveedores federados de autenticación.
/// Email no está aquí: tiene formulario propio (submit).
enum AuthProvider { google, apple }

/// ViewModel del formulario de autenticación.
///
/// Propietario (Regla 4): AuthScreen lo crea y lo destruye.
/// Habla solo con el contrato AuthenticationRepository.
/// No navega (Regla 5): el éxito se refleja vía authStateChanges
/// → AuthStateNotifier → AppRoot.
///
/// TODO(futuro): si aparece lógica de negocio real de autenticación
/// (verificación de email, vinculación de proveedores, reintentos),
/// extraerla a un AuthenticationService. Hoy no existe esa
/// responsabilidad (Regla 1).
class AuthFormViewModel extends ChangeNotifier {
  final AuthenticationRepository _repository;

  AuthFormMode _mode = AuthFormMode.login;
  AuthFormStatus _status = AuthFormStatus.idle;
  String? _errorMessage;

  String _name = '';
  String _email = '';
  String _password = '';

  AuthFormViewModel({required AuthenticationRepository repository})
      : _repository = repository;

  AuthFormMode get mode => _mode;
  AuthFormStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthFormStatus.loading;
  bool get isRegister => _mode == AuthFormMode.register;

  void toggleMode() {
    _mode = isRegister ? AuthFormMode.login : AuthFormMode.register;
    _errorMessage = null;
    _status = AuthFormStatus.idle;
    notifyListeners();
  }

  void updateName(String value) => _name = value;
  void updateEmail(String value) => _email = value;
  void updatePassword(String value) => _password = value;

  /// Valida y ejecuta login o registro según el modo.
  /// No retorna ruta ni navega: el cambio de sesión lo
  /// propaga el stream del repositorio.
  Future<void> submit() async {
    final validation = _validate();
    if (validation != null) {
      _errorMessage = validation;
      _status = AuthFormStatus.error;
      notifyListeners();
      return;
    }

    _status = AuthFormStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isRegister) {
        await _repository.signUpWithEmail(
          email: _email.trim(),
          password: _password,
          name: _name.trim(),
        );
      } else {
        await _repository.signInWithEmail(
          email: _email.trim(),
          password: _password,
        );
      }
      // Éxito: no hacemos nada. AppRoot reaccionará al stream.
      _status = AuthFormStatus.idle;
      notifyListeners();
    } on AuthFailure catch (f) {
      _errorMessage = _messageFor(f.reason);
      _status = AuthFormStatus.error;
      notifyListeners();
    }
  }

  /// Inicia el flujo del proveedor federado indicado. No navega
  /// (Regla 5). La cancelación del usuario no se reporta como
  /// error: cerrar el selector es una decisión, no un fallo.
  Future<void> submitWithProvider(AuthProvider provider) async {
    _status = AuthFormStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authenticate(provider);
      _status = AuthFormStatus.idle;
      notifyListeners();
    } on AuthFailure catch (f) {
      if (f.reason == AuthFailureReason.cancelled) {
        _status = AuthFormStatus.idle;
      } else {
        _errorMessage = _messageFor(f.reason);
        _status = AuthFormStatus.error;
      }
      notifyListeners();
    }
  }

  /// Despacha al método del contrato según el proveedor.
  Future<void> _authenticate(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => _repository.signInWithGoogle(),
      AuthProvider.apple => _repository.signInWithApple(),
    };
  }

  String? _validate() {
    if (isRegister && _name.trim().isEmpty) {
      return 'Cuéntanos tu nombre';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(_email.trim())) {
      return 'Ingresa un correo válido';
    }
    if (_password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  String _messageFor(AuthFailureReason reason) {
    return switch (reason) {
      AuthFailureReason.invalidCredentials => 'Correo o contraseña incorrectos',
      AuthFailureReason.emailAlreadyInUse =>
        'Ya existe una cuenta con este correo. ¿Quieres iniciar sesión?',
      AuthFailureReason.weakPassword =>
        'Esa contraseña es muy débil. Prueba una más segura',
      AuthFailureReason.invalidEmail => 'El formato del correo no es válido',
      AuthFailureReason.networkError =>
        'Sin conexión. Revisa tu internet e intenta de nuevo',
      AuthFailureReason.cancelled => 'Inicio de sesión cancelado',
      AuthFailureReason.unknown =>
        'Algo salió mal. Intenta de nuevo en un momento',
    };
  }
}
