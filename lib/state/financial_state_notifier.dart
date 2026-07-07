import 'package:flutter/material.dart';
import '../domain/financialCore/engine/financial_engine.dart';
import '../domain/models/financial_state.dart';
import '../domain/models/financial_profile.dart';

/// Estado financiero de la aplicación.
///
/// Recibe el perfil como DATO (nunca conoce a FinancialProfileNotifier):
/// el cableado ocurre en el composition root (main.dart), que escucha
/// los cambios de perfil y los empuja aquí. ADR-0002: el notifier no
/// calcula; entrega el contexto al Engine.
class FinancialStateNotifier extends ChangeNotifier {
  final FinancialEngine _engine;

  FinancialState _state = FinancialState.initial();
  FinancialProfile? _profile;
  bool _isLoading = false;
  String? _error;

  FinancialState get state => _state;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FinancialStateNotifier({required FinancialEngine engine}) : _engine = engine;

  /// Actualiza el contexto de plan y recalcula si cambió.
  /// Llamado desde el composition root cuando el perfil cambia.
  Future<void> setProfile(FinancialProfile? profile) async {
    if (identical(profile, _profile)) return;
    _profile = profile;
    await _recalculate();
  }

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _recalculate();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> process(FinancialEvent event) async {
    try {
      _state = await _engine.process(
        event: event,
        currentState: _state,
        profile: _profile,
      );
      _error = null;
    } catch (e) {
      _error = 'No se pudo procesar el movimiento';
    }
    notifyListeners();
  }

  Future<void> _recalculate() async {
    try {
      final now = DateTime.now();
      _state = await _engine.recalculate(
        month: now.month,
        year: now.year,
        profile: _profile,
      );
      _error = null;
    } catch (e) {
      _error = 'No se pudo cargar tu información financiera';
    }
    notifyListeners();
  }
}
