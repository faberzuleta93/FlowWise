import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../../../models/budget_state.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Alerta de agotamiento proyectado SOLO si ocurriría antes del
/// próximo ingreso esperado (ADR-0002 p.7: las decisiones se
/// comparan contra el próximo ingreso, no el calendario).
/// Lenguaje hipotético (p.5): "al ritmo actual... se agotaría".
class BlockDepletionDecisionRule implements DecisionRule {
  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final nextIncome = state.projection.nextIncomeDate;
    if (nextIncome == null) return [];

    final decisions = <FinancialDecision>[];
    _evaluate('Esenciales', 'essentials', state.budget.essentials,
        state.projection.essentialsDepletion, nextIncome, decisions);
    _evaluate('Estilo de vida', 'lifestyle', state.budget.lifestyle,
        state.projection.lifestyleDepletion, nextIncome, decisions);
    _evaluate('Futuro', 'future', state.budget.future,
        state.projection.futureDepletion, nextIncome, decisions);
    return decisions;
  }

  void _evaluate(
    String name,
    String idPrefix,
    BudgetBlock block,
    DateTime? depletion,
    DateTime nextIncome,
    List<FinancialDecision> decisions,
  ) {
    if (depletion == null) return;
    // Ya agotado: BudgetDecisionRule cubre ese caso (exceeded).
    if (block.remaining <= 0) return;
    // Solo si el agotamiento llegaría ANTES del próximo ingreso.
    if (!depletion.isBefore(nextIncome)) return;

    decisions.add(FinancialDecision(
      id: 'depletion_$idPrefix',
      type: DecisionType.budgetWarning,
      title: 'Ritmo de gasto alto',
      context: 'Al ritmo actual, $name se agotaría alrededor del '
          'día ${depletion.day}, antes de tu próximo pago '
          '(día ${nextIncome.day}).',
      priority: DecisionPriority.medium,
      category: DecisionCategory.budget,
      action: ReviewBudgetAction(blockName: name, exceeded: false),
      dismissible: true,
      generatedAt: DateTime.now(),
    ));
  }
}
