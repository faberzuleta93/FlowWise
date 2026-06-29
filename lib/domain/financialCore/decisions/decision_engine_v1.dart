import '../../models/financial_state.dart';
import '../../models/financial_decision.dart';
import '../../models/budget_state.dart';
import '../../models/liquidity_state.dart';
import '../../models/goal_progress.dart';
import '../../models/upcoming_obligation.dart';
import '../../models/financial_momentum.dart';
import 'decision_engine.dart';

class DecisionEngineV1 implements DecisionEngine {
  @override
  List<FinancialDecision> generate({
    required FinancialState state,
  }) {
    final decisions = <FinancialDecision>[];

    _evaluateBudget(state.budget, decisions);
    _evaluateLiquidity(state.liquidity, decisions);
    _evaluateObligations(state.obligations, decisions);
    _evaluateGoals(state.goals, state.liquidity, decisions);
    _evaluateMomentum(state.momentum, decisions);

    decisions.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return decisions;
  }

  void _evaluateBudget(
    BudgetState budget,
    List<FinancialDecision> decisions,
  ) {
    if (budget.essentials.status == BlockStatus.exceeded) {
      decisions.add(FinancialDecision(
        id: 'budget_essentials_exceeded',
        title: 'Revisa tus gastos esenciales',
        context: 'Excediste el límite del 50% este mes',
        priority: DecisionPriority.high,
        category: DecisionCategory.budget,
        actionType: DecisionActionType.reviewBudget,
        generatedAt: DateTime.now(),
      ));
    }
    if (budget.lifestyle.status == BlockStatus.exceeded) {
      decisions.add(FinancialDecision(
        id: 'budget_lifestyle_exceeded',
        title: 'Detén los gastos de estilo de vida',
        context: 'Superaste el 30% asignado',
        priority: DecisionPriority.high,
        category: DecisionCategory.budget,
        actionType: DecisionActionType.reviewBudget,
        generatedAt: DateTime.now(),
      ));
    }
    if (budget.lifestyle.status == BlockStatus.warning) {
      decisions.add(FinancialDecision(
        id: 'budget_lifestyle_warning',
        title: 'Estás cerca del límite',
        context:
            'Llevas el ${(budget.lifestyle.percentage * 100).toInt()}% de tu presupuesto de estilo de vida',
        priority: DecisionPriority.medium,
        category: DecisionCategory.budget,
        actionType: DecisionActionType.reviewBudget,
        generatedAt: DateTime.now(),
      ));
    }
  }

  void _evaluateLiquidity(
    LiquidityState liquidity,
    List<FinancialDecision> decisions,
  ) {
    if (liquidity.unassignedMoney > 0) {
      decisions.add(FinancialDecision(
        id: 'unassigned_money',
        title: 'Asigna tu dinero flotando',
        context: 'Tienes dinero sin trabajar este mes',
        priority: DecisionPriority.medium,
        category: DecisionCategory.liquidity,
        actionType: DecisionActionType.assignMoney,
        actionPayload: {'amount': liquidity.unassignedMoney},
        generatedAt: DateTime.now(),
      ));
    }
  }

  void _evaluateObligations(
    List<UpcomingObligation> obligations,
    List<FinancialDecision> decisions,
  ) {
    for (final o in obligations) {
      if (o.daysUntilDue <= 3) {
        decisions.add(FinancialDecision(
          id: 'obligation_urgent_${o.id}',
          title: 'Paga ${o.name}',
          context: 'Vence en ${o.daysUntilDue} días',
          priority: DecisionPriority.critical,
          category: DecisionCategory.credit,
          actionType: DecisionActionType.payCredit,
          actionPayload: {'obligationId': o.id},
          generatedAt: DateTime.now(),
          expiresAt: o.dueDate,
        ));
      }
    }
  }

  void _evaluateGoals(
    List<GoalProgress> goals,
    LiquidityState liquidity,
    List<FinancialDecision> decisions,
  ) {
    for (final goal in goals) {
      if (goal.percentage < 1.0 && liquidity.unassignedMoney > 0) {
        decisions.add(FinancialDecision(
          id: 'goal_contribute_${goal.id}',
          title: 'Aporta a ${goal.name}',
          context: 'Llevas el ${(goal.percentage * 100).toInt()}% de tu meta',
          priority: DecisionPriority.medium,
          category: DecisionCategory.goal,
          actionType: DecisionActionType.contributeToGoal,
          actionPayload: {'goalId': goal.id},
          generatedAt: DateTime.now(),
        ));
      }
    }
  }

  void _evaluateMomentum(
    FinancialMomentum momentum,
    List<FinancialDecision> decisions,
  ) {
    if (momentum.direction == MomentumDirection.improving) {
      decisions.add(FinancialDecision(
        id: 'momentum_positive',
        title: 'Vas mejor que el mes pasado',
        context: 'Sigue así, tu tendencia es positiva',
        priority: DecisionPriority.low,
        category: DecisionCategory.achievement,
        actionType: DecisionActionType.none,
        generatedAt: DateTime.now(),
      ));
    }
    if (momentum.direction == MomentumDirection.declining) {
      decisions.add(FinancialDecision(
        id: 'momentum_negative',
        title: 'Tu tendencia va a la baja',
        context: 'Este mes vas peor que el anterior',
        priority: DecisionPriority.high,
        category: DecisionCategory.momentum,
        actionType: DecisionActionType.reviewBudget,
        generatedAt: DateTime.now(),
      ));
    }
  }
}
