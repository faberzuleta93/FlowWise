import 'package:flutter/material.dart';
import '../../domain/models/movement_session.dart';
import '../../domain/models/financial_movement.dart';
import '../../domain/models/budget_category.dart';
import '../../domain/models/account.dart';
import '../../domain/financialCore/engine/financial_engine.dart';
import '../../state/financial_state_notifier.dart';

enum FormState { idle, loading, success, error }

class MovementFormViewModel extends ChangeNotifier {
  final FinancialStateNotifier _financialNotifier;
  late MovementSession _session;

  FormState _state = FormState.idle;
  String? _errorMessage;

  MovementFormViewModel({
    required FinancialStateNotifier financialNotifier,
    required MovementType type,
  }) : _financialNotifier = financialNotifier {
    _session = MovementSession(
      type: type,
      date: DateTime.now(),
    );
  }

  MovementSession get session => _session;
  FormState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isValid => _session.isValid;
  bool get isLoading => _state == FormState.loading;
  MovementType get type => _session.type;

  void updateAmount(double amount) {
    _session = _session.copyWith(amount: amount);
    notifyListeners();
  }

  void updateCurrency(String currencyCode) {
    _session = _session.copyWith(currencyCode: currencyCode);
    notifyListeners();
  }

  void updateCategory(BudgetCategory category) {
    _session = _session.copyWith(category: category);
    notifyListeners();
  }

  void updateAccount(Account account) {
    _session = _session.copyWith(account: account);
    notifyListeners();
  }

  void updateDestinationAccount(Account account) {
    _session = _session.copyWith(destinationAccount: account);
    notifyListeners();
  }

  void updateDate(DateTime date) {
    _session = _session.copyWith(date: date);
    notifyListeners();
  }

  void updateNotes(String notes) {
    _session = _session.copyWith(notes: notes.isEmpty ? null : notes);
    notifyListeners();
  }

  Future<bool> save() async {
    if (!isValid) return false;

    _state = FormState.loading;
    notifyListeners();

    try {
      final movement = _session.toMovement();
      final event = _buildEvent(movement);

      // Notifica al Core Financiero — actualiza todo el estado
      await _financialNotifier.process(event);

      _state = FormState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = FormState.error;
      _errorMessage = 'No se pudo guardar el movimiento';
      notifyListeners();
      return false;
    }
  }

  FinancialEvent _buildEvent(FinancialMovement movement) {
    final now = DateTime.now();
    return switch (_session.type) {
      MovementType.ingreso => IncomeRegistered(
          movement: movement,
          occurredAt: now,
        ),
      MovementType.gasto => ExpenseRegistered(
          movement: movement,
          occurredAt: now,
        ),
      MovementType.transferencia => TransferRegistered(
          movement: movement,
          occurredAt: now,
        ),
    };
  }

  void reset() {
    _session = MovementSession(
      type: _session.type,
      date: DateTime.now(),
    );
    _state = FormState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
