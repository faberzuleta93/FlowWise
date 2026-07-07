import 'package:flutter/foundation.dart';
import '../../domain/models/financial_profile.dart';
import '../../state/financial_profile_notifier.dart';

enum ProfileFormStatus { idle, saving, error }

/// ViewModel del formulario de perfil financiero inicial.
///
/// Propietario (Regla 4): FinancialProfileScreen lo crea y destruye.
/// No navega (Regla 5): AppRoot reacciona al cambio de estado.
class FinancialProfileFormViewModel extends ChangeNotifier {
  final FinancialProfileNotifier _notifier;

  ProfileFormStatus _status = ProfileFormStatus.idle;
  String? _errorMessage;

  double? _monthlyIncome;
  PayFrequency _payFrequency = PayFrequency.monthly;
  int? _payDay;

  FinancialProfileFormViewModel({required FinancialProfileNotifier notifier})
      : _notifier = notifier;

  ProfileFormStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _status == ProfileFormStatus.saving;
  PayFrequency get payFrequency => _payFrequency;

  /// Solo irregular no pregunta día de pago.
  bool get asksPayDay => _payFrequency != PayFrequency.irregular;

  /// V2.1: el selector cambia de tipo según la frecuencia.
  bool get asksWeekday => _payFrequency == PayFrequency.weekly;
  bool get asksDayOfMonth =>
      _payFrequency == PayFrequency.monthly ||
      _payFrequency == PayFrequency.biweekly;

  void updateIncome(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    _monthlyIncome = cleaned.isEmpty ? null : double.parse(cleaned);
  }

  void updateFrequency(PayFrequency value) {
    _payFrequency = value;
    if (!asksPayDay) _payDay = null;
    notifyListeners();
  }

  void updatePayDay(String value) {
    final parsed = int.tryParse(value.trim());
    _payDay = (parsed != null && parsed >= 1 && parsed <= 31) ? parsed : null;
  }

  /// V2.1: selector de día de semana (1=lunes...7=domingo).
  void updateWeekday(int weekday) {
    _payDay = weekday;
    notifyListeners();
  }

  Future<void> complete() async {
    _status = ProfileFormStatus.saving;
    notifyListeners();
    try {
      await _notifier.completeProfile(
        monthlyIncome: _monthlyIncome,
        payFrequency: _payFrequency,
        payDay: _payDay,
      );
      _status = ProfileFormStatus.idle;
    } catch (_) {
      _errorMessage = 'No se pudo guardar tu perfil. Intenta de nuevo';
      _status = ProfileFormStatus.error;
    }
    notifyListeners();
  }

  Future<void> postpone() async {
    _status = ProfileFormStatus.saving;
    notifyListeners();
    try {
      await _notifier.postpone();
      _status = ProfileFormStatus.idle;
    } catch (_) {
      _errorMessage = 'Algo salió mal. Intenta de nuevo';
      _status = ProfileFormStatus.error;
    }
    notifyListeners();
  }
}
