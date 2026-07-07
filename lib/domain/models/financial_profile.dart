/// Frecuencia con la que el usuario recibe sus ingresos.
enum PayFrequency { weekly, biweekly, monthly, irregular }

/// Estado del onboarding financiero, derivado del perfil.
enum OnboardingStatus { unknown, notOffered, offered, completed }

/// Situación financiera declarada por el usuario.
///
/// Pertenece al Core Financiero, no a la identidad: puede cambiar
/// con el tiempo (nuevo empleo, nuevo salario) sin afectar quién
/// es el usuario. El FinancialEngine la usa para proyecciones.
///
/// Nota semántica: un campo en null NO distingue por sí solo entre
/// "omitido" y "desconocido". La distinción la da [offeredAt]: si
/// es null, nunca se preguntó; si tiene valor y el campo es null,
/// fue omitido.
///
/// SEMÁNTICA DE [payDay] SEGÚN [payFrequency] (decisión V2.1,
/// FlowWise nace para Colombia — mensual/quincenal/semanal son
/// requisito de primera clase):
/// - monthly: día del mes (1-31). 31 en meses cortos = último día.
/// - biweekly: PRIMER día de pago del mes (1-31). El segundo pago
///   se deriva automáticamente (15 días después, saturado al fin
///   de mes) — no se almacenan dos campos.
/// - weekly: día de la semana en ISO 8601 (1=lunes...7=domingo,
///   igual que DateTime.weekday — cero fricción de conversión).
/// - irregular: payDay no aplica; sin proyección de ingreso.
///
/// Evolución documentada (ADR-0002): un Value Object PaySchedule
/// (monthly(day)/biweekly(firstDay)/weekly(weekday)) sería más
/// expresivo, pero es cirugía de modelo+mapper+formulario+migración.
/// Se adopta cuando el doble significado de payDay genere fricción
/// real, no por anticipación.
class FinancialProfile {
  final double? monthlyIncome;

  final PayFrequency payFrequency;

  /// Ver semántica por frecuencia en el doc de la clase.
  /// Null cuando se omitió o payFrequency es irregular.
  final int? payDay;

  final bool completed;

  final DateTime? offeredAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialProfile({
    this.monthlyIncome,
    this.payFrequency = PayFrequency.monthly,
    this.payDay,
    required this.completed,
    this.offeredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialProfile.empty() {
    final now = DateTime.now();
    return FinancialProfile(
      completed: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  OnboardingStatus get onboardingStatus {
    if (completed) return OnboardingStatus.completed;
    return offeredAt == null
        ? OnboardingStatus.notOffered
        : OnboardingStatus.offered;
  }

  FinancialProfile copyWith({
    double? monthlyIncome,
    PayFrequency? payFrequency,
    int? payDay,
    bool? completed,
    DateTime? offeredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialProfile(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      payFrequency: payFrequency ?? this.payFrequency,
      payDay: payDay ?? this.payDay,
      completed: completed ?? this.completed,
      offeredAt: offeredAt ?? this.offeredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
