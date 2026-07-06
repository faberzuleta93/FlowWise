import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/financial_profile.dart';
import '../../domain/repositories/financial_profile_repository.dart';
import '../mappers/financial_profile_mapper.dart';

/// Implementación local de [FinancialProfileRepository].
///
/// Comportamiento get-or-create: si no existe perfil persistido,
/// crea FinancialProfile.empty(), lo persiste y lo retorna. Así
/// esta implementación nunca retorna null en la práctica, aunque
/// el contrato lo permita para otras implementaciones futuras.
///
/// Regla 2: junto con el datasource de movimientos, único archivo
/// autorizado a importar shared_preferences. Regla 1: sin capa
/// datasource — no hay lógica de consulta que la justifique.
class SharedPreferencesFinancialProfileRepository
    implements FinancialProfileRepository {
  static const String _key = 'flowwise_financial_profile';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<FinancialProfile?> getCurrentProfile() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null) {
      final empty = FinancialProfile.empty();
      await prefs.setString(
          _key, jsonEncode(FinancialProfileMapper.toMap(empty)));
      return empty;
    }
    return FinancialProfileMapper.fromMap(
        jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(FinancialProfile profile) async {
    final prefs = await _prefs;
    await prefs.setString(
        _key, jsonEncode(FinancialProfileMapper.toMap(profile)));
  }

  @override
  Future<void> update(FinancialProfile profile) => save(profile);

  @override
  Future<void> delete() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }
}
