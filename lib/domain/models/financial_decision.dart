import '../financialCore/decisions/decision_action.dart';

// Tipos semánticos que la UI interpreta para mostrar
// el ícono, color y comportamiento correcto.
// El Core nunca define presentación.
enum DecisionType {
  budgetExceeded, // bloque superado
  budgetWarning, // bloque cerca del límite
  unassignedMoney, // dinero flotando
  obligationUrgent, // pago crítico próximo
  obligationUpcoming, // pago próximo
  goalContribution, // oportunidad de aportar a meta
  momentumPositive, // tendencia mejorando
  momentumNegative, // tendencia empeorando
  generalInfo, // informativo sin acción
}

enum DecisionPriority { critical, high, medium, low }

enum DecisionCategory {
  budget,
  credit,
  goal,
  liquidity,
  achievement,
  momentum,
}

class FinancialDecision {
  final String id;

  /// Tipo semántico — la UI decide el ícono y color.
  final DecisionType type;

  /// Texto corto y directo. Máx. 5 palabras.
  final String title;

  /// Contexto explicativo. Por qué es relevante ahora.
  final String context;

  final DecisionPriority priority;
  final DecisionCategory category;

  /// Acción tipada. Nunca un Map genérico.
  final DecisionAction action;

  /// Si es true, el usuario puede descartar la decisión.
  /// Si es false, permanece visible hasta que se resuelva.
  final bool dismissible;

  final DateTime generatedAt;
  final DateTime? expiresAt;

  // Preparado para IA Premium:
  // explanation, confidence, alternativeActions

  const FinancialDecision({
    required this.id,
    required this.type,
    required this.title,
    required this.context,
    required this.priority,
    required this.category,
    required this.action,
    required this.dismissible,
    required this.generatedAt,
    this.expiresAt,
  });
}
