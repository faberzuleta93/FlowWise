/// Frecuencia con la que el usuario recibe sus ingresos.
enum PayFrequency { weekly, biweekly, monthly, irregular }

/// Situación financiera declarada por el usuario.
///
/// Pertenece al Core Financiero, no a la identidad: puede cambiar
/// con el tiempo (nuevo empleo, nuevo salario) sin afectar quién
/// es el usuario. El FinancialEngine la usará para proyecciones.
class FinancialProfile {
  /// Ingreso mensual aproximado. Null → el usuario lo omitió.
  final double? monthlyIncome;

  final PayFrequency payFrequency;

  /// Día del mes en que recibe su pago principal (1-31).
  /// Null cuando payFrequency es irregular o se omitió.
  final int? payDay;

  /// True cuando el usuario completó el perfil financiero inicial.
  /// False cuando eligió "Lo haré después".
  final bool completed;

  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialProfile({
    this.monthlyIncome,
    this.payFrequency = PayFrequency.monthly,
    this.payDay,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Perfil vacío para usuarios que omiten el onboarding financiero.
  factory FinancialProfile.empty() {
    final now = DateTime.now();
    return FinancialProfile(
      completed: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  FinancialProfile copyWith({
    double? monthlyIncome,
    PayFrequency? payFrequency,
    int? payDay,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialProfile(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      payFrequency: payFrequency ?? this.payFrequency,
      payDay: payDay ?? this.payDay,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
