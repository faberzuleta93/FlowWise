import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Evalúa la liquidez disponible del usuario.
/// Genera decisiones cuando hay dinero sin asignar.
class LiquidityDecisionRule implements DecisionRule {
  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final unassigned = state.liquidity.unassignedMoney;
    if (unassigned <= 0) return [];

    return [
      FinancialDecision(
        id: 'liquidity_unassigned',
        type: DecisionType.unassignedMoney,
        title: 'Dinero sin trabajar',
        context: 'Tienes dinero flotando este mes. '
            'Asígnale un propósito.',
        priority: DecisionPriority.medium,
        category: DecisionCategory.liquidity,
        action: AssignMoneyAction(amount: unassigned),
        dismissible: true,
        generatedAt: DateTime.now(),
      ),
    ];
  }
}
