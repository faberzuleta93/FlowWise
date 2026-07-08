import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Pregunta por el pago esperado no registrado: payDay + 2 días de
/// gracia sin ingreso posterior. Desaparece en el mismo evento en
/// que se registra el ingreso (las decisiones se regeneran).
/// Filtro: accionable ✓ oportuna ✓ relevante ✓.
class ExpectedIncomeDecisionRule implements DecisionRule {
  static const int _graceDays = 2;

  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final ctx = state.decisionContext.expectedIncome;
    final daysSince = ctx.daysSinceExpected;

    if (daysSince == null ||
        daysSince < _graceDays ||
        ctx.incomeRegisteredSince) {
      return [];
    }

    return [
      FinancialDecision(
        id: 'expected_income_missing',
        type: DecisionType.generalInfo,
        title: '¿Ya recibiste tu pago?',
        context: 'Tu pago estaba previsto hace $daysSince días y '
            'aún no hay un ingreso registrado. Regístralo para '
            'mantener tu información al día.',
        priority: DecisionPriority.medium,
        category: DecisionCategory.liquidity,
        action: const RegisterMovementAction(
          reason: 'Registrar el pago recibido',
        ),
        dismissible: true,
        generatedAt: DateTime.now(),
      ),
    ];
  }
}
