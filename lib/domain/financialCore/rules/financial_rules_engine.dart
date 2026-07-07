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

// TODO(Sprint4-V2): ingeniería inversa frágil del ingreso
  // (allocated / 0.50). La V2 de proyecciones reescribe la
  // liquidez recibiendo el contexto directamente.
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
  /// Solo proyecta el ingreso con payFrequency == monthly,
  /// verificado explícitamente — silencio no es soporte.
  ProjectionState calculateProjection(
    BudgetState budget,
    FinancialProfile? profile,
  ) {
    final now = DateTime.now();
    final daysElapsed = now.day;

    final totalSpent =
        budget.essentials.spent + budget.lifestyle.spent + budget.future.spent;
    final dailyRate = daysElapsed > 0 ? totalSpent / daysElapsed : 0.0;

    // Proyección de ingreso: solo mensual con payDay conocido.
    DateTime? nextIncome;
    int? daysUntil;
    final payDay = profile?.payDay;
    if (profile?.payFrequency == PayFrequency.monthly && payDay != null) {
      nextIncome = _nextIncomeDate(now, payDay);
      daysUntil =
          nextIncome.difference(DateTime(now.year, now.month, now.day)).inDays;
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

  /// Regla de fechas aprobada: si hoy <= payDay efectivo → este mes;
  /// si ya pasó → el del mes siguiente. payDay 31 en meses cortos
  /// se interpreta como el último día del mes.
  DateTime _nextIncomeDate(DateTime now, int payDay) {
    final lastDayThisMonth = DateTime(now.year, now.month + 1, 0).day;
    final effectiveDay = payDay > lastDayThisMonth ? lastDayThisMonth : payDay;
    if (now.day <= effectiveDay) {
      return DateTime(now.year, now.month, effectiveDay);
    }
    final lastDayNextMonth = DateTime(now.year, now.month + 2, 0).day;
    final effectiveNext = payDay > lastDayNextMonth ? lastDayNextMonth : payDay;
    return DateTime(now.year, now.month + 1, effectiveNext);
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
