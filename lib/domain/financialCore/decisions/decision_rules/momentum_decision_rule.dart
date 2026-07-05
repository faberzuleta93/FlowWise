import '../../../models/financial_state.dart';
import '../../../models/financial_decision.dart';
import '../../../models/financial_momentum.dart';
import '../decision_rule.dart';
import '../decision_action.dart';

/// Evalúa la tendencia financiera del usuario.
/// Positiva → reconocimiento. Negativa → alerta.
/// Estable → sin decisión.
class MomentumDecisionRule implements DecisionRule {
  @override
  List<FinancialDecision> evaluate(FinancialState state) {
    final now = DateTime.now();

    return switch (state.momentum.direction) {
      MomentumDirection.improving => [
          FinancialDecision(
            id: 'momentum_positive',
            type: DecisionType.momentumPositive,
            title: 'Vas mejorando',
            context: 'Tu tendencia este mes es positiva. '
                'Sigue así.',
            priority: DecisionPriority.low,
            category: DecisionCategory.achievement,
            action: const NoAction(),
            dismissible: true,
            generatedAt: now,
          ),
        ],
      MomentumDirection.declining => [
          FinancialDecision(
            id: 'momentum_negative',
            type: DecisionType.momentumNegative,
            title: 'Tendencia a la baja',
            context: 'Este mes vas peor que el anterior. '
                'Revisa tus gastos.',
            priority: DecisionPriority.high,
            category: DecisionCategory.momentum,
            action: const ReviewBudgetAction(
              blockName: 'general',
              exceeded: false,
            ),
            dismissible: false,
            generatedAt: now,
          ),
        ],
      MomentumDirection.stable => [],
    };
  }
}
