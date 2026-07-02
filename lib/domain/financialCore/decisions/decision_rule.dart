import '../../models/financial_state.dart';
import '../../models/financial_decision.dart';

/// Contrato que toda regla de decisión debe cumplir.
/// Cada implementación tiene exactamente una responsabilidad.
/// El DecisionEngine orquesta — las reglas evalúan.
abstract class DecisionRule {
  /// Evalúa el estado financiero actual y retorna
  /// las decisiones que aplican. Lista vacía si ninguna aplica.
  List<FinancialDecision> evaluate(FinancialState state);
}
