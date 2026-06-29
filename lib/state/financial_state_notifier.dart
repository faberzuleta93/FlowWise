import 'package:flutter/material.dart';
import '../domain/financialCore/engine/financial_engine.dart';
import '../domain/models/financial_state.dart';

class FinancialStateNotifier extends ChangeNotifier {
  final FinancialEngine _engine;

  FinancialState _state = FinancialState.initial();
  bool _isLoading = false;
  String? _error;

  FinancialState get state => _state;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FinancialStateNotifier({required FinancialEngine engine}) : _engine = engine;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      _state = await _engine.recalculate(
        month: now.month,
        year: now.year,
      );
    } catch (e) {
      _error = 'No se pudo cargar tu información financiera';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> process(FinancialEvent event) async {
    try {
      _state = await _engine.process(
        event: event,
        currentState: _state,
      );
      _error = null;
    } catch (e) {
      _error = 'No se pudo procesar el movimiento';
    }
    notifyListeners();
  }
}
