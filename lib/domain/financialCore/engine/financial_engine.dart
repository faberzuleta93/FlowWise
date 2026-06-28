// Interfaz del engine
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

// Implementación V1
class FinancialEngineV1 implements FinancialEngine {
  final MovementRepository _movementRepository;
  final FinancialRulesEngine _rules;
  final RecommendationEngine _recommendations;

  FinancialEngineV1({
    required MovementRepository movementRepository,
  })  : _movementRepository = movementRepository,
        _rules = FinancialRulesEngine(),
        _recommendations = RecommendationEngine();

  @override
  Future<FinancialState> process({
    required FinancialEvent event,
    required FinancialState currentState,
  }) async {
    // 1. Persistir el evento
    await _persistEvent(event);

    // 2. Recalcular el estado completo
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
    // 1. Obtener todos los movimientos del mes
    final movements = await _movementRepository.getByMonth(year, month);

    // 2. Aplicar reglas financieras
    final monthSummary = _rules.calculateMonthSummary(movements);
    final budgetState = _rules.calculateBudget(movements, monthSummary);
    final liquidity = _rules.calculateLiquidity(movements, budgetState);
    final wealth = _rules.calculateWealth(movements);

    // 3. Generar recomendaciones
    final recommendations = _recommendations.generate(
      budget: budgetState,
      liquidity: liquidity,
      obligations: [], // Sprint 3
      goals: [], // Sprint 3
    );

    // 4. Retornar nuevo estado inmutable
    return FinancialState(
      month: month,
      year: year,
      monthSummary: monthSummary,
      liquidity: liquidity,
      budget: budgetState,
      wealth: wealth,
      obligations: [], // Sprint 3
      goals: [], // Sprint 3
      recentMovements: movements.take(5).toList(),
      recommendations: recommendations,
      calculatedAt: DateTime.now(),
    );
  }

  Future<void> _persistEvent(FinancialEvent event) async {
    switch (event) {
      case IncomeRegistered(:final movement):
      case ExpenseRegistered(:final movement):
      case TransferRegistered(:final movement):
        await _movementRepository.save(movement);
      default:
        break; // otros eventos — Sprint 3
    }
  }
}
