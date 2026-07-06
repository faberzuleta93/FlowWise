import 'package:flutter/foundation.dart';
import '../../domain/models/financial_profile.dart';
import '../../state/financial_profile_notifier.dart';

enum ProfileFormStatus { idle, saving, error }

/// ViewModel del formulario de perfil financiero inicial.
///
/// Propietario (Regla 4): FinancialProfileScreen lo crea y destruye.
/// No navega (Regla 5): al completar o posponer, el
/// FinancialProfileNotifier notifica y AppRoot re-resuelve la ruta.
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
  bool get asksPayDay => _payFrequency != PayFrequency.irregular;

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

  /// Todos los campos son opcionales por decisión de producto:
  /// FlowWise guía, no obliga.
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
