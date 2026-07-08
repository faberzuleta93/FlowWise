import '../../models/financial_movement.dart';
import '../../models/budget_category.dart';
import '../../models/month_summary.dart';
import '../../models/liquidity_state.dart';
import '../../models/budget_state.dart';
import '../../models/wealth_state.dart';
import '../../models/financial_health.dart';
import '../../models/financial_momentum.dart';
import '../../models/projection_state.dart';
import '../../models/financial_profile.dart';
import '../../models/decision_context.dart';

class FinancialRulesEngine {
  MonthSummary calculateMonthSummary(List<FinancialMovement> movements) {
    final income = movements
        .where((m) => m.type == MovementType.ingreso)
        .fold(0.0, (sum, m) => sum + m.amount);

    final expenses = movements
        .where((m) => m.type == MovementType.gasto)
        .fold(0.0, (sum, m) => sum + m.amount);

    return MonthSummary(
      totalIncome: income,
      totalExpenses: expenses,
      balance: income - expenses,
      savingsRate: income > 0 ? ((income - expenses) / income * 100) : 0,
    );
  }

  BudgetState calculateBudget(
    List<FinancialMovement> movements,
    MonthSummary summary, {
    double? declaredMonthlyIncome,
  }) {
    // ADR-0002: lo declarado planifica, lo registrado mide.
    // La condición es el DATO (monthlyIncome != null), no el
    // estado administrativo del onboarding. Nunca se mezclan.
    final income = declaredMonthlyIncome ?? summary.totalIncome;

    final essentialsSpent =
        _spentInBlock(movements, BudgetBlockType.esenciales);
    final lifestyleSpent =
        _spentInBlock(movements, BudgetBlockType.estiloDeVida);
    final futureSpent = _spentInBlock(movements, BudgetBlockType.futuro);

    final essentials =
        _buildBlock(allocated: income * 0.50, spent: essentialsSpent);
    final lifestyle =
        _buildBlock(allocated: income * 0.30, spent: lifestyleSpent);
    final future = _buildBlock(allocated: income * 0.20, spent: futureSpent);

    return BudgetState(
      essentials: essentials,
      lifestyle: lifestyle,
      future: future,
      semaforo: _calculateSemaforo(essentials, lifestyle, future),
      thermometerValue: _calculateThermometer(summary),
      basis: declaredMonthlyIncome != null
          ? BudgetBasis.declaredPlan
          : BudgetBasis.registeredIncome,
    );
  }

  LiquidityState calculateLiquidity(
    List<FinancialMovement> movements,
    BudgetState budget, {
    required double income,
    int? daysUntilNextIncome,
  }) {
    final totalSpent =
        budget.essentials.spent + budget.lifestyle.spent + budget.future.spent;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemainingInMonth = daysInMonth - now.day + 1;

    // Horizonte de liquidez (ADR-0002): el próximo ingreso esperado
    // cuando se conoce; el fin de mes como degradación elegante.
    // "¿Cuánto puedo gastar hasta que vuelva a entrar dinero?"
    final horizon = daysUntilNextIncome ?? daysRemainingInMonth;
    final effectiveHorizon = horizon < 1 ? 1 : horizon;

    final lifestyleRemaining = budget.lifestyle.remaining;
    final availableToday = lifestyleRemaining / effectiveHorizon;

    return LiquidityState(
      availableToday: availableToday,
      unassignedMoney: income - totalSpent,
      balanceByAccount: _calculateAccountBalances(movements),
    );
  }

  /// Proyecciones al ritmo observado (ADR-0002, principio 5).
  /// Irregular no proyecta ingreso; mensual, quincenal y semanal
  /// son de primera clase (V2.1, FlowWise nace para Colombia).
  ProjectionState calculateProjection(
    BudgetState budget,
    FinancialProfile? profile,
  ) {
    final now = DateTime.now();
    final daysElapsed = now.day;

    final totalSpent =
        budget.essentials.spent + budget.lifestyle.spent + budget.future.spent;
    final dailyRate = daysElapsed > 0 ? totalSpent / daysElapsed : 0.0;

    // ADR-0002 principio 7: el horizonte es el próximo ingreso
    // esperado, no el fin de calendario.
    DateTime? nextIncome;
    int? daysUntil;
    if (profile?.payFrequency != null &&
        profile?.payFrequency != PayFrequency.irregular) {
      nextIncome = _nextIncomeDate(now, profile!.payFrequency, profile.payDay);
      if (nextIncome != null) {
        daysUntil = nextIncome
            .difference(DateTime(now.year, now.month, now.day))
            .inDays;
      }
    }

    return ProjectionState(
      daysUntilNextIncome: daysUntil,
      nextIncomeDate: nextIncome,
      dailySpendingRate: dailyRate,
      essentialsDepletion: _depletionDate(budget.essentials, now, daysElapsed),
      lifestyleDepletion: _depletionDate(budget.lifestyle, now, daysElapsed),
      futureDepletion: _depletionDate(budget.future, now, daysElapsed),
    );
  }

  /// Construye los contextos de decisión (ADR-0002 p.6 y p.8).
  /// [previousMonthsMovements] son los movimientos de los 3 meses
  /// anteriores completos, provistos por el Engine (opción A:
  /// la tendencia se deriva de la fuente de verdad, nunca de
  /// conclusiones persistidas).
  DecisionContext buildDecisionContext({
    required List<FinancialMovement> currentMovements,
    required List<List<FinancialMovement>> previousMonthsMovements,
    required FinancialProfile? profile,
    required ProjectionState projection,
  }) {
    final now = DateTime.now();
    return DecisionContext(
      profile: ProfileContext(
        completed: profile?.completed ?? false,
        movementCountThisMonth: currentMovements.length,
      ),
      incomeAlignment: _buildIncomeAlignment(
        previousMonthsMovements,
        profile?.monthlyIncome,
      ),
      expectedIncome: _buildExpectedIncome(
        currentMovements,
        profile,
        now,
      ),
    );
  }

  /// Tendencia declarado vs registrado sobre 3 meses completos.
  /// Umbral de alineación: ±15% del declarado (evita reportar
  /// variaciones normales como discrepancia).
  IncomeAlignmentContext _buildIncomeAlignment(
    List<List<FinancialMovement>> previousMonths,
    double? declaredIncome,
  ) {
    if (declaredIncome == null || previousMonths.length < 3) {
      return IncomeAlignmentContext(
        status: IncomeAlignmentStatus.insufficientHistory,
        declaredIncome: declaredIncome,
        monthsObserved: previousMonths.length,
      );
    }

    final monthlyIncomes = previousMonths
        .map((movements) => movements
            .where((m) => m.type == MovementType.ingreso)
            .fold(0.0, (sum, m) => sum + m.amount))
        .toList();

    // Meses sin ingresos registrados no evidencian tendencia.
    if (monthlyIncomes.any((income) => income <= 0)) {
      return IncomeAlignmentContext(
        status: IncomeAlignmentStatus.insufficientHistory,
        declaredIncome: declaredIncome,
        monthsObserved: previousMonths.length,
      );
    }

    final average =
        monthlyIncomes.reduce((a, b) => a + b) / monthlyIncomes.length;
    const tolerance = 0.15;
    final upper = declaredIncome * (1 + tolerance);
    final lower = declaredIncome * (1 - tolerance);

    // Sostenida: los TRES meses del mismo lado (tendencia, no foto).
    final allAbove = monthlyIncomes.every((i) => i > upper);
    final allBelow = monthlyIncomes.every((i) => i < lower);

    return IncomeAlignmentContext(
      status: allAbove
          ? IncomeAlignmentStatus.aboveDeclared
          : allBelow
              ? IncomeAlignmentStatus.belowDeclared
              : IncomeAlignmentStatus.aligned,
      averageRegistered: average,
      declaredIncome: declaredIncome,
      monthsObserved: previousMonths.length,
    );
  }

  /// ¿El ingreso esperado más reciente ya fue registrado?
  ExpectedIncomeContext _buildExpectedIncome(
    List<FinancialMovement> currentMovements,
    FinancialProfile? profile,
    DateTime now,
  ) {
    final payDay = profile?.payDay;
    final frequency = profile?.payFrequency;
    if (payDay == null ||
        frequency == null ||
        frequency == PayFrequency.irregular) {
      return ExpectedIncomeContext.empty();
    }

    final lastExpected = _lastExpectedIncomeDate(now, frequency, payDay);
    if (lastExpected == null) return ExpectedIncomeContext.empty();

    final today = DateTime(now.year, now.month, now.day);
    final daysSince = today.difference(lastExpected).inDays;

    final registeredSince = currentMovements.any((m) =>
        m.type == MovementType.ingreso && !m.date.isBefore(lastExpected));

    return ExpectedIncomeContext(
      lastExpectedDate: lastExpected,
      daysSinceExpected: daysSince,
      incomeRegisteredSince: registeredSince,
    );
  }

  // ── FECHAS DE INGRESO ────────────────────────────

  /// Calcula la fecha del próximo ingreso esperado según la
  /// frecuencia declarada (ver semántica de payDay en
  /// FinancialProfile). Null si irregular o sin payDay.
  DateTime? _nextIncomeDate(
    DateTime now,
    PayFrequency frequency,
    int? payDay,
  ) {
    if (payDay == null) return null;
    return switch (frequency) {
      PayFrequency.monthly => _nextMonthly(now, payDay),
      PayFrequency.biweekly => _nextBiweekly(now, payDay),
      PayFrequency.weekly => _nextWeekly(now, payDay),
      PayFrequency.irregular => null,
    };
  }

  /// payDay = día del mes. 31 en meses cortos = último día.
  DateTime _nextMonthly(DateTime now, int payDay) {
    final lastDayThisMonth = DateTime(now.year, now.month + 1, 0).day;
    final effectiveDay = payDay > lastDayThisMonth ? lastDayThisMonth : payDay;
    if (now.day <= effectiveDay) {
      return DateTime(now.year, now.month, effectiveDay);
    }
    final lastDayNextMonth = DateTime(now.year, now.month + 2, 0).day;
    final effectiveNext = payDay > lastDayNextMonth ? lastDayNextMonth : payDay;
    return DateTime(now.year, now.month + 1, effectiveNext);
  }

  /// payDay = primer pago del mes. El segundo se deriva: 15 días
  /// después, saturado al último día del mes.
  DateTime _nextBiweekly(DateTime now, int primaryPayDay) {
    final lastDayThisMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstPay =
        primaryPayDay > lastDayThisMonth ? lastDayThisMonth : primaryPayDay;
    final secondPayRaw = firstPay + 15;
    final secondPay =
        secondPayRaw > lastDayThisMonth ? lastDayThisMonth : secondPayRaw;

    final candidates = <DateTime>[
      DateTime(now.year, now.month, firstPay),
      DateTime(now.year, now.month, secondPay),
    ];
    for (final candidate in candidates) {
      if (!candidate.isBefore(DateTime(now.year, now.month, now.day))) {
        return candidate;
      }
    }
    // Ambos pagos de este mes ya pasaron: el primero del siguiente.
    final lastDayNextMonth = DateTime(now.year, now.month + 2, 0).day;
    final nextFirstPay =
        primaryPayDay > lastDayNextMonth ? lastDayNextMonth : primaryPayDay;
    return DateTime(now.year, now.month + 1, nextFirstPay);
  }

  /// payDay = día de la semana ISO 8601 (1=lunes...7=domingo).
  DateTime _nextWeekly(DateTime now, int weekday) {
    final today = DateTime(now.year, now.month, now.day);
    final daysUntil = (weekday - today.weekday) % 7;
    return today.add(Duration(days: daysUntil));
  }

  /// Fecha de pago esperada más reciente que ya pasó (o es hoy),
  /// DENTRO del mes en curso (los meses previos ya se evalúan
  /// por la tendencia de alineación).
  DateTime? _lastExpectedIncomeDate(
    DateTime now,
    PayFrequency frequency,
    int payDay,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(now.year, now.month + 1, 0).day;

    switch (frequency) {
      case PayFrequency.monthly:
        final day = payDay > lastDay ? lastDay : payDay;
        final date = DateTime(now.year, now.month, day);
        return date.isAfter(today) ? null : date;
      case PayFrequency.biweekly:
        final first = payDay > lastDay ? lastDay : payDay;
        final secondRaw = first + 15;
        final second = secondRaw > lastDay ? lastDay : secondRaw;
        final dates = [
          DateTime(now.year, now.month, second),
          DateTime(now.year, now.month, first),
        ];
        for (final d in dates) {
          if (!d.isAfter(today)) return d;
        }
        return null;
      case PayFrequency.weekly:
        final delta = (today.weekday - payDay) % 7;
        return today.subtract(Duration(days: delta));
      case PayFrequency.irregular:
        return null;
    }
  }

  /// Fecha estimada de agotamiento del bloque AL RITMO PROPIO del
  /// bloque (su gasto / días transcurridos). Null si no se agota
  /// manteniendo el ritmo, o si no hay ritmo observable.
  DateTime? _depletionDate(BudgetBlock block, DateTime now, int daysElapsed) {
    if (daysElapsed <= 0 || block.spent <= 0) return null;
    if (block.remaining <= 0) return DateTime(now.year, now.month, now.day);
    final blockDailyRate = block.spent / daysElapsed;
    if (blockDailyRate <= 0) return null;
    final daysToDepletion = (block.remaining / blockDailyRate).ceil();
    final depletion = now.add(Duration(days: daysToDepletion));
    // Solo es relevante si ocurre dentro del mes en curso.
    if (depletion.month != now.month || depletion.year != now.year) {
      return null;
    }
    return depletion;
  }

  WealthState calculateWealth(List<FinancialMovement> movements) {
    final balances = _calculateAccountBalances(movements);
    final totalAssets =
        balances.values.where((b) => b > 0).fold(0.0, (s, b) => s + b);
    final totalLiabilities =
        balances.values.where((b) => b < 0).fold(0.0, (s, b) => s + b.abs());

    return WealthState(
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      netWorth: totalAssets - totalLiabilities,
    );
  }

  FinancialHealth calculateHealth(
    MonthSummary summary,
    BudgetState budget,
  ) {
    // V1: score básico basado en semáforo
    // Sprint de gamificación: enriquecer con streaks y logros
    double score = 50;
    if (budget.semaforo == BudgetSemaforo.green) score = 75;
    if (budget.semaforo == BudgetSemaforo.red) score = 25;
    if (summary.savingsRate > 20) score += 10;
    if (summary.savingsRate <= 0) score -= 20;
    score = score.clamp(0, 100);

    final level = switch (score) {
      <= 20 => HealthLevel.critical,
      <= 40 => HealthLevel.low,
      <= 60 => HealthLevel.moderate,
      <= 80 => HealthLevel.good,
      _ => HealthLevel.excellent,
    };

    return FinancialHealth(
      score: score,
      level: level,
      trend: HealthTrend.stable,
      lastUpdated: DateTime.now(),
    );
  }

  FinancialMomentum calculateMomentum(MonthSummary summary) {
    // V1: sin datos históricos aún — siempre estable
    // V2: comparar con mes anterior desde repositorio
    return FinancialMomentum.initial();
  }

  // ── HELPERS PRIVADOS ────────────────────────────

  double _spentInBlock(
    List<FinancialMovement> movements,
    BudgetBlockType block,
  ) {
    final blockCategoryIds = DefaultCategories.gastos
        .where((c) => c.block == block)
        .map((c) => c.id)
        .toSet();

    return movements
        .where((m) =>
            m.type == MovementType.gasto &&
            blockCategoryIds.contains(m.categoryId))
        .fold(0.0, (sum, m) => sum + m.amount);
  }

  BudgetBlock _buildBlock({
    required double allocated,
    required double spent,
  }) {
    final percentage =
        allocated > 0 ? (spent / allocated).clamp(0.0, double.infinity) : 0.0;
    return BudgetBlock(
      allocated: allocated,
      spent: spent,
      remaining: allocated - spent,
      percentage: percentage,
      status: percentage >= 1.0
          ? BlockStatus.exceeded
          : percentage >= 0.85
              ? BlockStatus.warning
              : BlockStatus.ok,
    );
  }

  BudgetSemaforo _calculateSemaforo(
    BudgetBlock e,
    BudgetBlock l,
    BudgetBlock f,
  ) {
    if (e.status == BlockStatus.exceeded || l.status == BlockStatus.exceeded) {
      return BudgetSemaforo.red;
    }
    if (e.status == BlockStatus.warning || l.status == BlockStatus.warning) {
      return BudgetSemaforo.yellow;
    }
    return BudgetSemaforo.green;
  }

  double _calculateThermometer(MonthSummary summary) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthProgress = now.day / daysInMonth;
    final budgetUsed = summary.totalIncome > 0
        ? summary.totalExpenses / summary.totalIncome
        : 0.0;
    return budgetUsed - monthProgress;
  }

  Map<String, double> _calculateAccountBalances(
      List<FinancialMovement> movements) {
    final Map<String, double> balances = {};
    for (final m in movements) {
      switch (m.type) {
        case MovementType.ingreso:
          balances[m.accountId] = (balances[m.accountId] ?? 0) + m.amount;
        case MovementType.gasto:
          balances[m.accountId] = (balances[m.accountId] ?? 0) - m.amount;
        case MovementType.transferencia:
          balances[m.accountId] = (balances[m.accountId] ?? 0) - m.amount;
          if (m.destinationAccountId != null) {
            balances[m.destinationAccountId!] =
                (balances[m.destinationAccountId!] ?? 0) + m.amount;
          }
      }
    }
    return balances;
  }
}
