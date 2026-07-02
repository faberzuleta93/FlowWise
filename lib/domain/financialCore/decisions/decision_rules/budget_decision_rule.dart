import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../../../models/budget_state.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Evalúa el estado de los bloques 50/30/20.
/// Genera decisiones cuando un bloque es excedido o está en riesgo.
class BudgetDecisionRule implements DecisionRule {
  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final decisions = <FinancialDecision>[];
    final now = DateTime.now();

    _evaluateBlock(
      block: state.budget.essentials,
      blockName: 'Esenciales',
      decisions: decisions,
      now: now,
      idPrefix: 'essentials',
    );

    _evaluateBlock(
      block: state.budget.lifestyle,
      blockName: 'Estilo de vida',
      decisions: decisions,
      now: now,
      idPrefix: 'lifestyle',
    );

    _evaluateBlock(
      block: state.budget.future,
      blockName: 'Futuro',
      decisions: decisions,
      now: now,
      idPrefix: 'future',
    );

    return decisions;
  }

  void _evaluateBlock({
    required BudgetBlock block,
    required String blockName,
    required List<FinancialDecision> decisions,
    required DateTime now,
    required String idPrefix,
  }) {
    if (block.status == BlockStatus.exceeded) {
      decisions.add(FinancialDecision(
        id: 'budget_${idPrefix}_exceeded',
        type: DecisionType.budgetExceeded,
        title: 'Límite superado',
        context: 'Superaste el presupuesto de $blockName '
            'por \$${block.overage.toStringAsFixed(0)}',
        priority: DecisionPriority.high,
        category: DecisionCategory.budget,
        action: ReviewBudgetAction(
          blockName: blockName,
          exceeded: true,
          overage: block.overage,
        ),
        dismissible: false,
        generatedAt: now,
      ));
      return;
    }

    if (block.status == BlockStatus.warning) {
      decisions.add(FinancialDecision(
        id: 'budget_${idPrefix}_warning',
        type: DecisionType.budgetWarning,
        title: 'Cerca del límite',
        context: '$blockName al '
            '${(block.percentage * 100).toInt()}% '
            'del presupuesto',
        priority: DecisionPriority.medium,
        category: DecisionCategory.budget,
        action: ReviewBudgetAction(
          blockName: blockName,
          exceeded: false,
        ),
        dismissible: true,
        generatedAt: now,
      ));
    }
  }
}
