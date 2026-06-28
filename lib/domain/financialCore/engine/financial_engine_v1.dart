class FinancialEngineV1 implements FinancialEngine {
  final MovementRepository _movementRepository;
  final FinancialRulesEngine _rules;
  final DecisionEngine _decisionEngine; // MEJORA 2

  FinancialEngineV1({
    required MovementRepository movementRepository,
  })  : _movementRepository = movementRepository,
        _rules = FinancialRulesEngine(),
        _decisionEngine = DecisionEngineV1();

  @override
  Future<FinancialState> recalculate({
    required int month,
    required int year,
  }) async {
    final movements = await _movementRepository.getByMonth(year, month);

    // 1. Calcular estado financiero
    final monthSummary = _rules.calculateMonthSummary(movements);
    final budgetState = _rules.calculateBudget(movements, monthSummary);
    final liquidity = _rules.calculateLiquidity(movements, budgetState);
    final wealth = _rules.calculateWealth(movements);
    final health = _rules.calculateHealth(monthSummary, budgetState);
    final momentum = _rules.calculateMomentum(monthSummary);

    // 2. Construir estado parcial para el DecisionEngine
    final partialState = FinancialState(
      month: month,
      year: year,
      monthSummary: monthSummary,
      liquidity: liquidity,
      budget: budgetState,
      wealth: wealth,
      health: health,
      momentum: momentum,
      obligations: [],
      goals: [],
      recentMovements: movements.take(5).toList(),
      decisions: [], // vacío aún
      calculatedAt: DateTime.now(),
    );

    // 3. DecisionEngine consume el estado y produce decisiones
    final decisions = _decisionEngine.generate(state: partialState); // MEJORA 6

    // 4. Estado final con decisiones incluidas
    return partialState.copyWith(decisions: decisions);
  }
}
