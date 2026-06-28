class FinancialState {
  // ── ESTADO DEL MES ────────────────────────────
  final MonthSummary monthSummary;

  // ── LIQUIDEZ ──────────────────────────────────
  final LiquidityState liquidity;

  // ── PRESUPUESTO 50/30/20 ──────────────────────
  final BudgetState budget;

  // ── ESTADO FINANCIERO (patrimonio) ────────────
  final WealthState wealth;

  // ── SALUD FINANCIERA (base para gamificación) ─
  final FinancialHealth health; // MEJORA 1

  // ── MOMENTUM (¿cómo viene el usuario?) ────────
  final FinancialMomentum momentum; // MEJORA 5

  // ── OBLIGACIONES ──────────────────────────────
  final List<UpcomingObligation> obligations;

  // ── METAS ─────────────────────────────────────
  final List<GoalProgress> goals;

  // ── MOVIMIENTOS RECIENTES ─────────────────────
  final List<FinancialMovement> recentMovements;

  // ── DECISIONES (no recomendaciones) ──────────
  final List<FinancialDecision> decisions; // MEJORA 2

  // ── METADATA ──────────────────────────────────
  final DateTime calculatedAt;
  final int month;
  final int year;
}
