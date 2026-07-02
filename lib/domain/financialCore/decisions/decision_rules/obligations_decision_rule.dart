import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../../../models/upcoming_obligation.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Evalúa las obligaciones próximas a vencer.
/// Las críticas (≤3 días) no son descartables.
/// Las próximas (≤7 días) sí lo son.
class ObligationsDecisionRule implements DecisionRule {
  static const int _criticalDays = 3;
  static const int _upcomingDays = 7;

  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final decisions = <FinancialDecision>[];
    final now = DateTime.now();

    for (final obligation in state.obligations) {
      if (obligation.daysUntilDue <= _criticalDays) {
        decisions.add(_buildCritical(obligation, now));
      } else if (obligation.daysUntilDue <= _upcomingDays) {
        decisions.add(_buildUpcoming(obligation, now));
      }
    }

    return decisions;
  }

  FinancialDecision _buildCritical(
    UpcomingObligation o,
    DateTime now,
  ) {
    return FinancialDecision(
      id: 'obligation_critical_${o.id}',
      type: DecisionType.obligationUrgent,
      title: 'Pago urgente',
      context: '${o.name} vence '
          '${o.daysUntilDue == 0 ? "hoy" : "en ${o.daysUntilDue} días"}',
      priority: DecisionPriority.critical,
      category: DecisionCategory.credit,
      action: PayCreditAction(
        obligationId: o.id,
        obligationName: o.name,
        daysUntilDue: o.daysUntilDue,
        amountDue: o.amount,
      ),
      dismissible: false,
      generatedAt: now,
      expiresAt: o.dueDate,
    );
  }

  FinancialDecision _buildUpcoming(
    UpcomingObligation o,
    DateTime now,
  ) {
    return FinancialDecision(
      id: 'obligation_upcoming_${o.id}',
      type: DecisionType.obligationUpcoming,
      title: 'Pago próximo',
      context: '${o.name} vence en ${o.daysUntilDue} días',
      priority: DecisionPriority.high,
      category: DecisionCategory.credit,
      action: PayCreditAction(
        obligationId: o.id,
        obligationName: o.name,
        daysUntilDue: o.daysUntilDue,
        amountDue: o.amount,
      ),
      dismissible: true,
      generatedAt: now,
      expiresAt: o.dueDate,
    );
  }
}
