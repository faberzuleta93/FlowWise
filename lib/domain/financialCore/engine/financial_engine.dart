import '../../models/financial_state.dart';
import '../../models/financial_movement.dart';
import '../../models/financial_profile.dart';

sealed class FinancialEvent {
  final DateTime occurredAt;
  const FinancialEvent({required this.occurredAt});
}

class IncomeRegistered extends FinancialEvent {
  final FinancialMovement movement;
  const IncomeRegistered({
    required this.movement,
    required super.occurredAt,
  });
}

class ExpenseRegistered extends FinancialEvent {
  final FinancialMovement movement;
  const ExpenseRegistered({
    required this.movement,
    required super.occurredAt,
  });
}

class TransferRegistered extends FinancialEvent {
  final FinancialMovement movement;
  const TransferRegistered({
    required this.movement,
    required super.occurredAt,
  });
}

// Preparado para sprints futuros
class CreditRegistered extends FinancialEvent {
  final String creditId;
  const CreditRegistered({
    required this.creditId,
    required super.occurredAt,
  });
}

class GoalCreated extends FinancialEvent {
  final String goalId;
  const GoalCreated({
    required this.goalId,
    required super.occurredAt,
  });
}

/// Contrato del motor financiero de FlowWise.
///
/// ADR-0002: el Engine calcula sobre un contexto — el perfil entra
/// como PARÁMETRO, nunca como dependencia del constructor. Puro,
/// determinista, testeable sin mocks. El perfil representa el plan;
/// los movimientos, la realidad; el Engine interpreta la relación
/// entre ambos.
abstract class FinancialEngine {
  Future<FinancialState> process({
    required FinancialEvent event,
    required FinancialState currentState,
    FinancialProfile? profile,
  });

  Future<FinancialState> recalculate({
    required int month,
    required int year,
    FinancialProfile? profile,
  });
}
