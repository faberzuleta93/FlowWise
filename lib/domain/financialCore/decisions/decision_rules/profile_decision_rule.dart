import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Sugiere completar el perfil financiero con prioridad escalonada
/// según el compromiso demostrado (movimientos del mes):
/// 0-5 → low · 6-20 → medium · >20 → high. Nunca critical.
/// Filtro (ADR-0002): accionable ✓ oportuna ✓ relevante ✓.
class ProfileDecisionRule implements DecisionRule {
  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final ctx = state.decisionContext.profile;
    if (ctx.completed) return [];

    final count = ctx.movementCountThisMonth;
    final priority = count > 20
        ? DecisionPriority.high
        : count > 5
            ? DecisionPriority.medium
            : DecisionPriority.low;

    return [
      FinancialDecision(
        id: 'profile_incomplete',
        type: DecisionType.generalInfo,
        title: 'Completa tu perfil',
        context: count > 5
            ? 'Ya registraste $count movimientos este mes. Con tu '
                'perfil completo, FlowWise puede planificar contigo.'
            : 'Cuéntanos tu ingreso y FlowWise podrá planificar contigo.',
        priority: priority,
        category: DecisionCategory.liquidity,
        action: const RegisterMovementAction(
          reason: 'Completar perfil financiero',
        ),
        dismissible: true,
        generatedAt: DateTime.now(),
      ),
    ];
  }
}
