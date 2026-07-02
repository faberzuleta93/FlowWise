// Modelos tipados que reemplazan Map<String, dynamic>.
// Cada acción representa una intención concreta del sistema.
// La UI interpreta cada tipo sin conocer la lógica financiera.

sealed class DecisionAction {
  const DecisionAction();
}

/// El usuario no necesita hacer nada. Solo informativo.
class NoAction extends DecisionAction {
  const NoAction();
}

/// El usuario debe asignar dinero flotante.
class AssignMoneyAction extends DecisionAction {
  final double amount;
  const AssignMoneyAction({required this.amount});
}

/// El usuario debe revisar un bloque de presupuesto.
class ReviewBudgetAction extends DecisionAction {
  final String blockName;
  final bool exceeded;
  final double overage;
  const ReviewBudgetAction({
    required this.blockName,
    required this.exceeded,
    this.overage = 0,
  });
}

/// El usuario debe pagar una obligación.
class PayCreditAction extends DecisionAction {
  final String obligationId;
  final String obligationName;
  final int daysUntilDue;
  final double amountDue;
  const PayCreditAction({
    required this.obligationId,
    required this.obligationName,
    required this.daysUntilDue,
    required this.amountDue,
  });
}

/// El usuario puede aportar a una meta.
class ContributeToGoalAction extends DecisionAction {
  final String goalId;
  final String goalName;
  final double suggestedAmount;
  final double remainingAmount;
  const ContributeToGoalAction({
    required this.goalId,
    required this.goalName,
    required this.suggestedAmount,
    required this.remainingAmount,
  });
}

/// El usuario debe registrar un movimiento pendiente.
class RegisterMovementAction extends DecisionAction {
  final String reason;
  const RegisterMovementAction({required this.reason});
}
