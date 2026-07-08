import '../../models/financial_state.dart';
import '../../models/financial_decision.dart';
import 'decision_engine.dart';
import 'decision_rule.dart';
import 'decision_rules/budget_decision_rule.dart';
import 'decision_rules/liquidity_decision_rule.dart';
import 'decision_rules/obligations_decision_rule.dart';
import 'decision_rules/goals_decision_rule.dart';
import 'decision_rules/momentum_decision_rule.dart';
import 'decision_rules/profile_decision_rule.dart';
import 'decision_rules/expected_income_decision_rule.dart';
import 'decision_rules/income_alignment_decision_rule.dart';
import 'decision_rules/block_depletion_decision_rule.dart';

/// Orquesta la ejecución de todas las reglas de decisión.
/// No contiene lógica financiera — solo coordina y consolida.
/// Para agregar una nueva regla: implementa DecisionRule
/// y agrégala a _rules. Nada más.
class DecisionEngineImpl implements DecisionEngine {
  final List<DecisionRule> _rules;

  DecisionEngineImpl()
      : _rules = [
          BudgetDecisionRule(),
          LiquidityDecisionRule(),
          ObligationsDecisionRule(),
          GoalsDecisionRule(),
          MomentumDecisionRule(),
          ProfileDecisionRule(),
          ExpectedIncomeDecisionRule(),
          IncomeAlignmentDecisionRule(),
          BlockDepletionDecisionRule(),
        ];

  /// Constructor para testing — permite inyectar reglas mock.
  DecisionEngineImpl.withRules(List<DecisionRule> rules) : _rules = rules;

  @override
  List<FinancialDecision> generate({
    required FinancialState state,
  }) {
    final decisions = <FinancialDecision>[];

    for (final rule in _rules) {
      decisions.addAll(rule.evaluate(state));
    }

    _sortByPriority(decisions);
    return decisions;
  }

  void _sortByPriority(List<FinancialDecision> decisions) {
    decisions.sort(
      (a, b) => a.priority.index.compareTo(b.priority.index),
    );
  }
}
