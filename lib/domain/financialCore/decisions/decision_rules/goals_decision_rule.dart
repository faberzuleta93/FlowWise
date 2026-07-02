import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Evalúa el progreso de las metas activas.
/// Solo genera decisión si hay dinero disponible para aportar.
class GoalsDecisionRule implements DecisionRule {
  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final unassigned = state.liquidity.unassignedMoney;
    if (unassigned <= 0) return [];

    final decisions = <FinancialDecision>[];
    final now = DateTime.now();

    for (final goal in state.goals) {
      if (goal.percentage >= 1.0) continue;

      final remaining = goal.target - goal.current;
      final suggested = unassigned < remaining ? unassigned : remaining;

      decisions.add(FinancialDecision(
        id: 'goal_contribute_${goal.id}',
        type: DecisionType.goalContribution,
        title: 'Aporta a tu meta',
        context: '${goal.name} al '
            '${(goal.percentage * 100).toInt()}%. '
            'Faltan \$${remaining.toStringAsFixed(0)}',
        priority: DecisionPriority.medium,
        category: DecisionCategory.goal,
        action: ContributeToGoalAction(
          goalId: goal.id,
          goalName: goal.name,
          suggestedAmount: suggested,
          remainingAmount: remaining,
        ),
        dismissible: true,
        generatedAt: now,
      ));
    }

    return decisions;
  }
}
