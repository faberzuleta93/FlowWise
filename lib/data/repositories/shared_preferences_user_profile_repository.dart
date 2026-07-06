import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../mappers/user_profile_mapper.dart';

/// Implementación local de [UserProfileRepository].
///
/// Persistencia únicamente: no conoce Firebase, AuthSession ni
/// proveedores. La siembra del perfil desde la sesión es
/// responsabilidad del flujo posterior a la autenticación
/// (UserProfileNotifier), no de este repositorio.
class SharedPreferencesUserProfileRepository implements UserProfileRepository {
  static const String _key = 'flowwise_user_profile';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<UserProfile?> getCurrentProfile() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return UserProfileMapper.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(UserProfile profile) async {
    final prefs = await _prefs;
    await prefs.setString(_key, jsonEncode(UserProfileMapper.toMap(profile)));
  }

  @override
  Future<void> update(UserProfile profile) => save(profile);

  @override
  Future<void> delete() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }
}
