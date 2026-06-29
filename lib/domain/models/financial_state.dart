import 'month_summary.dart';
import 'liquidity_state.dart';
import 'budget_state.dart';
import 'wealth_state.dart';
import 'financial_health.dart';
import 'financial_momentum.dart';
import 'financial_decision.dart';
import 'goal_progress.dart';
import 'upcoming_obligation.dart';
import 'financial_movement.dart';

class FinancialState {
  final MonthSummary monthSummary;
  final LiquidityState liquidity;
  final BudgetState budget;
  final WealthState wealth;
  final FinancialHealth health;
  final FinancialMomentum momentum;
  final List<UpcomingObligation> obligations;
  final List<GoalProgress> goals;
  final List<FinancialMovement> recentMovements;
  final List<FinancialDecision> decisions;
  final DateTime calculatedAt;
  final int month;
  final int year;

  const FinancialState({
    required this.monthSummary,
    required this.liquidity,
    required this.budget,
    required this.wealth,
    required this.health,
    required this.momentum,
    required this.obligations,
    required this.goals,
    required this.recentMovements,
    required this.decisions,
    required this.calculatedAt,
    required this.month,
    required this.year,
  });

  factory FinancialState.initial() {
    final now = DateTime.now();
    return FinancialState(
      monthSummary: MonthSummary.empty(),
      liquidity: LiquidityState.empty(),
      budget: BudgetState.empty(),
      wealth: WealthState.empty(),
      health: FinancialHealth.initial(),
      momentum: FinancialMomentum.initial(),
      obligations: [],
      goals: [],
      recentMovements: [],
      decisions: [],
      calculatedAt: now,
      month: now.month,
      year: now.year,
    );
  }

  FinancialState copyWith({
    MonthSummary? monthSummary,
    LiquidityState? liquidity,
    BudgetState? budget,
    WealthState? wealth,
    FinancialHealth? health,
    FinancialMomentum? momentum,
    List<UpcomingObligation>? obligations,
    List<GoalProgress>? goals,
    List<FinancialMovement>? recentMovements,
    List<FinancialDecision>? decisions,
    DateTime? calculatedAt,
    int? month,
    int? year,
  }) {
    return FinancialState(
      monthSummary: monthSummary ?? this.monthSummary,
      liquidity: liquidity ?? this.liquidity,
      budget: budget ?? this.budget,
      wealth: wealth ?? this.wealth,
      health: health ?? this.health,
      momentum: momentum ?? this.momentum,
      obligations: obligations ?? this.obligations,
      goals: goals ?? this.goals,
      recentMovements: recentMovements ?? this.recentMovements,
      decisions: decisions ?? this.decisions,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
