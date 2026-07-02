enum BlockStatus { ok, warning, exceeded }

enum BudgetSemaforo { green, yellow, red }

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

  const BudgetState({
    required this.essentials,
    required this.lifestyle,
    required this.future,
    required this.semaforo,
    required this.thermometerValue,
  });

  factory BudgetState.empty() => BudgetState(
        essentials: BudgetBlock.empty(),
        lifestyle: BudgetBlock.empty(),
        future: BudgetBlock.empty(),
        semaforo: BudgetSemaforo.green,
        thermometerValue: 0,
      );
}
