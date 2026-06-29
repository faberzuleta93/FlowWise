import '../../models/financial_state.dart';
import '../../models/financial_movement.dart';

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

// Preparado para Sprint 3
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

abstract class FinancialEngine {
  Future<FinancialState> process({
    required FinancialEvent event,
    required FinancialState currentState,
  });

  Future<FinancialState> recalculate({
    required int month,
    required int year,
  });
}
