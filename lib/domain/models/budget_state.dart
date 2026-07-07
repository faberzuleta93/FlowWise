enum BlockStatus { ok, warning, exceeded }

enum BudgetSemaforo { green, yellow, red }

/// Origen del presupuesto (ADR-0002).
///
/// declaredPlan: los montos asignados expresan el plan del usuario
/// (ingreso declarado en su perfil financiero).
/// registeredIncome: los montos se derivan de los ingresos
/// registrados en el mes (modo medición pura).
///
/// Se modela como enum del dominio, no como booleano: documenta
/// una decisión de dominio, no una implementación.
enum BudgetBasis { declaredPlan, registeredIncome }

class BudgetBlock {
  final double allocated;
  final double spent;
  final double remaining;
  final double percentage;
  final BlockStatus status;

  /// Monto excedido. Es 0 si no hay exceso.
  double get overage => spent > allocated ? spent - allocated : 0;

  const BudgetBlock({
    required this.allocated,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.status,
  });

  factory BudgetBlock.empty() => const BudgetBlock(
        allocated: 0,
        spent: 0,
        remaining: 0,
        percentage: 0,
        status: BlockStatus.ok,
      );
}

class BudgetState {
  final BudgetBlock essentials;
  final BudgetBlock lifestyle;
  final BudgetBlock future;
  final BudgetSemaforo semaforo;
  final double thermometerValue;

  /// Origen de los montos asignados. El objeto explica
  /// completamente su origen (ADR-0002).
  final BudgetBasis basis;

  const BudgetState({
    required this.essentials,
    required this.lifestyle,
    required this.future,
    required this.semaforo,
    required this.thermometerValue,
    required this.basis,
  });

  factory BudgetState.empty() => BudgetState(
        essentials: BudgetBlock.empty(),
        lifestyle: BudgetBlock.empty(),
        future: BudgetBlock.empty(),
        semaforo: BudgetSemaforo.green,
        thermometerValue: 0,
        // Estado vacío: por defecto representa el modo medición.
        // El Engine reemplazará este valor durante el primer cálculo
        // real; este default no tiene significado funcional.
        basis: BudgetBasis.registeredIncome,
      );
}
