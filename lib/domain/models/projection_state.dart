/// Proyecciones del Engine: escenarios condicionales, no predicciones.
///
/// ADR-0002 (principio 5): el Engine solo proyecta aquello cuya
/// hipótesis puede explicar. La hipótesis de todos estos valores es
/// el ritmo observado (gasto acumulado / días transcurridos)
/// mantenido constante. "Al ritmo actual, se agotaría alrededor
/// del 22" — nunca "se agotará el 22".
///
/// Distinción de tiempos del dominio: LiquidityState describe el
/// presente; ProjectionState describe un escenario.
class ProjectionState {
  /// Días hasta el próximo ingreso esperado (payDay mensual).
  /// Null → no hay proyección de ingreso (sin payDay, frecuencia
  /// no mensual, o perfil ausente): el sistema opera en modo
  /// degradado usando el fin de mes como horizonte.
  final int? daysUntilNextIncome;

  /// Fecha estimada del próximo ingreso. Null en modo degradado.
  final DateTime? nextIncomeDate;

  /// Ritmo de gasto observado: gasto acumulado del mes dividido
  /// entre los días transcurridos. Es la hipótesis enunciable de
  /// todas las proyecciones de agotamiento.
  final double dailySpendingRate;

  /// Fecha estimada de agotamiento de cada bloque AL RITMO ACTUAL.
  /// Null → el bloque no se agota este mes manteniendo el ritmo.
  final DateTime? essentialsDepletion;
  final DateTime? lifestyleDepletion;
  final DateTime? futureDepletion;

  const ProjectionState({
    this.daysUntilNextIncome,
    this.nextIncomeDate,
    required this.dailySpendingRate,
    this.essentialsDepletion,
    this.lifestyleDepletion,
    this.futureDepletion,
  });

  factory ProjectionState.empty() =>
      const ProjectionState(dailySpendingRate: 0);
}
