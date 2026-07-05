import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'movement_datasource.dart';

/// Persiste movimientos serializados en SharedPreferences.
/// No conoce el modelo de dominio [FinancialMovement] —
/// solo trabaja con Map<String, dynamic> ya serializados.
class SharedPreferencesMovementDatasource implements MovementDatasource {
  static const String _key = 'flowwise_movements';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<void> save(Map<String, dynamic> movementData) async {
    final prefs = await _prefs;
    final all = await getAll();
    all.add(movementData);
    await prefs.setString(_key, jsonEncode(all));
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> delete(String id) async {
    final prefs = await _prefs;
    final all = await getAll();
    all.removeWhere((m) => m['id'] == id);
    await prefs.setString(_key, jsonEncode(all));
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }
}
