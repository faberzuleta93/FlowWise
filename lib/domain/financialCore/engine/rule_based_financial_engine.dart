import '../../../domain/repositories/movement_repository.dart';
import '../../models/financial_state.dart';
import '../../models/financial_profile.dart';
import '../../models/financial_movement.dart';
import '../rules/financial_rules_engine.dart';
import '../decisions/decision_engine.dart';
import '../decisions/decision_engine_impl.dart';
import 'financial_engine.dart';

/// Motor financiero basado en reglas deterministas.
///
/// ADR-0002: interpreta la relación entre el plan (perfil) y la
/// realidad (movimientos). El perfil entra como parámetro — el
/// Engine calcula sobre un contexto, no usa colaboradores.
/// Mismos movimientos + mismo perfil = misma respuesta, siempre.
class RuleBasedFinancialEngine implements FinancialEngine {
  final MovementRepository _movementRepository;
  final FinancialRulesEngine _rules;
  final DecisionEngine _decisionEngine;

  RuleBasedFinancialEngine({
    required MovementRepository movementRepository,
  })  : _movementRepository = movementRepository,
        _rules = FinancialRulesEngine(),
        _decisionEngine = DecisionEngineImpl();

  @override
  Future<FinancialState> process({
    required FinancialEvent event,
    required FinancialState currentState,
    FinancialProfile? profile,
  }) async {
    await _persistEvent(event);
    return recalculate(
      month: currentState.month,
      year: currentState.year,
      profile: profile,
    );
  }

  @override
  Future<FinancialState> recalculate({
    required int month,
    required int year,
    FinancialProfile? profile,
  }) async {
    final movements = await _movementRepository.getByMonth(year, month);

    final monthSummary = _rules.calculateMonthSummary(movements);
    final budget = _rules.calculateBudget(
      movements,
      monthSummary,
      declaredMonthlyIncome: profile?.monthlyIncome,
    );
    final projection = _rules.calculateProjection(budget, profile);
    final liquidity = _rules.calculateLiquidity(
      movements,
      budget,
      income: profile?.monthlyIncome ?? monthSummary.totalIncome,
      daysUntilNextIncome: projection.daysUntilNextIncome,
    );
    final wealth = _rules.calculateWealth(movements);
    final health = _rules.calculateHealth(monthSummary, budget);
    final momentum = _rules.calculateMomentum(monthSummary);

    // Opción A (ADR-0002): la tendencia se deriva de la fuente de
    // verdad. El Engine (único con repositorio) trae los 3 meses
    // previos; las reglas solo leen interpretaciones.
    final previousMonths = <List<FinancialMovement>>[];
    for (var i = 1; i <= 3; i++) {
      final target = DateTime(year, month - i);
      previousMonths.add(
        await _movementRepository.getByMonth(target.year, target.month),
      );
    }
    final decisionContext = _rules.buildDecisionContext(
      currentMovements: movements,
      previousMonthsMovements: previousMonths,
      profile: profile,
      projection: projection,
    );

    final partialState = FinancialState(
      month: month,
      year: year,
      monthSummary: monthSummary,
      liquidity: liquidity,
      budget: budget,
      wealth: wealth,
      health: health,
      momentum: momentum,
      projection: projection,
      decisionContext: decisionContext,
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
