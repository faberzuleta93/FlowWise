/// Contextos de decisión: interpretaciones del Engine que las
/// DecisionRule consumen para decidir y EXPLICAR.
///
/// ADR-0002 principio 6: el Engine interpreta; las reglas deciden.
/// ADR-0002 principio 8: modelos de dominio, nunca hechos aislados.
/// Cada contexto encapsula la conclusión Y la evidencia enunciable
/// (principio 3): la regla nunca calcula, pero siempre puede
/// explicar con datos observables.
///
/// Crece por conceptos de negocio, no por variables: nuevas
/// decisiones agregan contextos cohesivos, no bools dispersos.
library;

/// Estado del perfil respecto al compromiso demostrado del usuario.
class ProfileContext {
  /// True cuando el usuario completó el perfil financiero.
  final bool completed;

  /// Movimientos registrados en el mes en curso: la evidencia
  /// del compromiso (escala la prioridad de completar el perfil).
  final int movementCountThisMonth;

  const ProfileContext({
    required this.completed,
    required this.movementCountThisMonth,
  });

  factory ProfileContext.empty() =>
      const ProfileContext(completed: false, movementCountThisMonth: 0);
}

/// Relación entre el ingreso declarado y el registrado.
enum IncomeAlignmentStatus {
  aligned,
  aboveDeclared,
  belowDeclared,
  insufficientHistory,
}

class IncomeAlignmentContext {
  final IncomeAlignmentStatus status;

  /// Evidencia: promedio mensual registrado en el período observado.
  final double? averageRegistered;

  /// Evidencia: ingreso declarado contra el que se compara.
  final double? declaredIncome;

  /// Evidencia: meses completos observados (la tendencia requiere 3).
  final int monthsObserved;

  const IncomeAlignmentContext({
    required this.status,
    this.averageRegistered,
    this.declaredIncome,
    required this.monthsObserved,
  });

  factory IncomeAlignmentContext.empty() => const IncomeAlignmentContext(
        status: IncomeAlignmentStatus.insufficientHistory,
        monthsObserved: 0,
      );
}

/// Estado del ingreso esperado más reciente (¿ya se registró?).
class ExpectedIncomeContext {
  /// Fecha del ingreso esperado más reciente que ya pasó.
  /// Null → no hay proyección o aún no ha pasado ninguno este mes.
  final DateTime? lastExpectedDate;

  /// Días transcurridos desde esa fecha. Null si no aplica.
  final int? daysSinceExpected;

  /// True si existe un ingreso registrado en o después de la fecha
  /// esperada (el pago llegó y fue registrado).
  final bool incomeRegisteredSince;

  const ExpectedIncomeContext({
    this.lastExpectedDate,
    this.daysSinceExpected,
    required this.incomeRegisteredSince,
  });

  factory ExpectedIncomeContext.empty() =>
      const ExpectedIncomeContext(incomeRegisteredSince: false);
}

/// Agregado de contextos que viaja en FinancialState.
class DecisionContext {
  final ProfileContext profile;
  final IncomeAlignmentContext incomeAlignment;
  final ExpectedIncomeContext expectedIncome;

  const DecisionContext({
    required this.profile,
    required this.incomeAlignment,
    required this.expectedIncome,
  });

  factory DecisionContext.empty() => DecisionContext(
        profile: ProfileContext.empty(),
        incomeAlignment: IncomeAlignmentContext.empty(),
        expectedIncome: ExpectedIncomeContext.empty(),
      );
}
