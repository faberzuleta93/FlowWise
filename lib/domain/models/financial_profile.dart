/// Frecuencia con la que el usuario recibe sus ingresos.
enum PayFrequency { weekly, biweekly, monthly, irregular }

/// Estado del onboarding financiero, derivado del perfil.
///
/// unknown: el perfil aún no se ha cargado (solo lo usa la capa
/// de estado mientras resuelve; nunca se deriva del modelo).
enum OnboardingStatus { unknown, notOffered, offered, completed }

/// Situación financiera declarada por el usuario.
///
/// Pertenece al Core Financiero, no a la identidad: puede cambiar
/// con el tiempo (nuevo empleo, nuevo salario) sin afectar quién
/// es el usuario. El FinancialEngine la usará para proyecciones.
///
/// Nota semántica: un campo en null NO distingue por sí solo entre
/// "omitido" (el usuario no quiso responder) y "desconocido" (nunca
/// se preguntó). La distinción la da [offeredAt]: si es null, nunca
/// se preguntó; si tiene valor y el campo es null, fue omitido.
class FinancialProfile {
  /// Ingreso mensual aproximado. Null → omitido o desconocido
  /// (ver nota semántica de la clase).
  final double? monthlyIncome;

  final PayFrequency payFrequency;

  /// Día del mes en que recibe su pago principal (1-31).
  /// Null cuando payFrequency es irregular o se omitió.
  final int? payDay;

  /// True cuando el usuario completó el perfil financiero inicial.
  /// False cuando eligió "Lo haré después" o nunca se le ofreció.
  final bool completed;

  /// Momento en que se le mostró el flujo de perfil por primera
  /// vez. Null → nunca se le ha ofrecido. El flujo guiado se
  /// muestra una sola vez por cuenta-dispositivo.
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

  /// Perfil vacío para usuarios que aún no pasan por el onboarding.
  factory FinancialProfile.empty() {
    final now = DateTime.now();
    return FinancialProfile(
      completed: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Estado del onboarding derivado del propio perfil.
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
