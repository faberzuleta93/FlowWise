import 'package:flutter/foundation.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/user_profile.dart';
import '../domain/repositories/user_profile_repository.dart';

/// Estado de la identidad del usuario en FlowWise.
///
/// Responsabilidad única: el UserProfile. Aquí vive la siembra
/// desde la sesión (flujo posterior a autenticación): si no hay
/// perfil persistido, se crea desde AuthSession y se guarda.
/// El repositorio permanece "tonto"; este notifier orquesta.
class UserProfileNotifier extends ChangeNotifier {
  final UserProfileRepository _repository;

  UserProfile? _profile;
  bool _loading = false;

  UserProfileNotifier({required UserProfileRepository repository})
      : _repository = repository;

  UserProfile? get profile => _profile;

  /// Carga el perfil; si no existe, lo siembra desde la sesión.
  /// Idempotente: llamadas repetidas no duplican trabajo.
  Future<void> loadFrom(AuthSession session) async {
    if (_loading || _profile != null) return;
    _loading = true;

    final existing = await _repository.getCurrentProfile();
    if (existing != null) {
      _profile = existing;
    } else {
      final seeded = UserProfile(
        id: session.uid,
        name: session.displayName ?? 'Usuario',
        email: session.email,
        photoUrl: session.photoUrl,
      );
      await _repository.save(seeded);
      _profile = seeded;
    }

    _loading = false;
    notifyListeners();
  }

  /// Limpia el estado en memoria al cerrar sesión (el perfil
  /// persistido se conserva para el próximo login local).
  void clear() {
    _profile = null;
    _loading = false;
    notifyListeners();
  }
}
