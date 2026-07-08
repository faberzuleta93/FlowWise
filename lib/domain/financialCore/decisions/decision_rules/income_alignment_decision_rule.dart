import '../../../../core/utils/formatters.dart';
import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../../../models/decision_context.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Sugiere actualizar el declarado ante discrepancia SOSTENIDA
/// (3 meses del mismo lado, ±15%). ADR-0002 p.3: la decisión
/// enuncia su evidencia. FlowWise sugiere; nunca auto-ajusta.
class IncomeAlignmentDecisionRule implements DecisionRule {
  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final ctx = state.decisionContext.incomeAlignment;
    final average = ctx.averageRegistered;
    final declared = ctx.declaredIncome;

    final sustained = ctx.status == IncomeAlignmentStatus.aboveDeclared ||
        ctx.status == IncomeAlignmentStatus.belowDeclared;
    if (!sustained || average == null || declared == null) return [];

    final direction =
        ctx.status == IncomeAlignmentStatus.aboveDeclared ? 'más' : 'menos';

    return [
      FinancialDecision(
        id: 'income_misaligned_${ctx.status.name}',
        type: DecisionType.generalInfo,
        title: 'Tu ingreso real cambió',
        context: 'En los últimos ${ctx.monthsObserved} meses '
            'registraste en promedio ${formatCurrency(average)}, '
            '$direction que tu ingreso declarado de '
            '${formatCurrency(declared)}. ¿Actualizamos tu plan?',
        priority: DecisionPriority.medium,
        category: DecisionCategory.budget,
        action: UpdateFinancialProfileAction(suggestedIncome: average),
        dismissible: true,
        generatedAt: DateTime.now(),
      ),
    ];
  }
}
