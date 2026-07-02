import '../../../domain/repositories/movement_repository.dart';
import '../../models/financial_state.dart';
import '../rules/financial_rules_engine.dart';
import '../decisions/decision_engine.dart';
import '../decisions/decision_engine_impl.dart';
import 'financial_engine.dart';

class FinancialEngineV1 implements FinancialEngine {
  final MovementRepository _movementRepository;
  final FinancialRulesEngine _rules;
  final DecisionEngine _decisionEngine;

  FinancialEngineV1({
    required MovementRepository movementRepository,
  })  : _movementRepository = movementRepository,
        _rules = FinancialRulesEngine(),
        _decisionEngine = DecisionEngineImpl();

  @override
  Future<FinancialState> process({
    required FinancialEvent event,
    required FinancialState currentState,
  }) async {
    await _persistEvent(event);
    return recalculate(
      month: currentState.month,
      year: currentState.year,
    );
  }

  @override
  Future<FinancialState> recalculate({
    required int month,
    required int year,
  }) async {
    final movements = await _movementRepository.getByMonth(year, month);

    final monthSummary = _rules.calculateMonthSummary(movements);
    final budget = _rules.calculateBudget(movements, monthSummary);
    final liquidity = _rules.calculateLiquidity(movements, budget);
    final wealth = _rules.calculateWealth(movements);
    final health = _rules.calculateHealth(monthSummary, budget);
    final momentum = _rules.calculateMomentum(monthSummary);

    final partialState = FinancialState(
      month: month,
      year: year,
      monthSummary: monthSummary,
      liquidity: liquidity,
      budget: budget,
      wealth: wealth,
      health: health,
      momentum: momentum,
      obligations: [],
      goals: [],
      recentMovements: movements.take(5).toList(),
      decisions: [],
      calculatedAt: DateTime.now(),
    );

    final decisions = _decisionEngine.generate(state: partialState);

    return partialState.copyWith(decisions: decisions);
  }

  Future<void> _persistEvent(FinancialEvent event) async {
    switch (event) {
      case IncomeRegistered(:final movement):
        await _movementRepository.save(movement);
      case ExpenseRegistered(:final movement):
        await _movementRepository.save(movement);
      case TransferRegistered(:final movement):
        await _movementRepository.save(movement);
      default:
        break;
    }
  }
}
