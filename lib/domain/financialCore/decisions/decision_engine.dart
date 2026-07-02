import '../../models/financial_state.dart';
import '../../models/financial_decision.dart';

/// Contrato del motor de decisiones.
/// El engine no evalúa — orquesta reglas.
abstract class DecisionEngine {
  List<FinancialDecision> generate({
    required FinancialState state,
  });
}
