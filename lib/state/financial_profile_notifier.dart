import 'package:flutter/foundation.dart';
import '../domain/models/financial_profile.dart';
import '../domain/repositories/financial_profile_repository.dart';

/// Estado del perfil financiero.
///
/// Expone el OnboardingStatus que consume AppRoot para resolver
/// rutas, y las operaciones del flujo inicial (completar/posponer).
/// Propietario (Regla 4): main.dart lo crea; vive toda la app.
class FinancialProfileNotifier extends ChangeNotifier {
  final FinancialProfileRepository _repository;

  FinancialProfile? _profile;
  bool _loading = false;

  FinancialProfileNotifier({required FinancialProfileRepository repository})
      : _repository = repository;

  FinancialProfile? get profile => _profile;

  /// unknown mientras el perfil no se haya cargado.
  OnboardingStatus get onboardingStatus =>
      _profile?.onboardingStatus ?? OnboardingStatus.unknown;

  /// Ingreso declarado, solo si el perfil fue completado.
  double? get declaredMonthlyIncome =>
      (_profile?.completed ?? false) ? _profile?.monthlyIncome : null;

  /// Carga el perfil una sola vez (idempotente). El contrato
  /// permite null; se maneja defensivamente con empty().
  Future<void> load() async {
    if (_loading || _profile != null) return;
    _loading = true;
    final loaded = await _repository.getCurrentProfile();
    _profile = loaded ?? FinancialProfile.empty();
    _loading = false;
    notifyListeners();
  }

  /// El usuario completó el flujo inicial.
  Future<void> completeProfile({
    double? monthlyIncome,
    required PayFrequency payFrequency,
    int? payDay,
  }) async {
    final now = DateTime.now();
    final base = _profile ?? FinancialProfile.empty();
    final updated = base.copyWith(
      monthlyIncome: monthlyIncome,
      payFrequency: payFrequency,
      payDay: payDay,
      completed: true,
      offeredAt: base.offeredAt ?? now,
      updatedAt: now,
    );
    await _repository.update(updated);
    _profile = updated;
    notifyListeners();
  }

  /// El usuario eligió "Lo haré después". Se registra offeredAt
  /// para no volver a interrumpir (el pendiente vivirá como
  /// FinancialDecision — Sprint 4).
  Future<void> postpone() async {
    final now = DateTime.now();
    final base = _profile ?? FinancialProfile.empty();
    final updated = base.copyWith(offeredAt: now, updatedAt: now);
    await _repository.update(updated);
    _profile = updated;
    notifyListeners();
  }
}
