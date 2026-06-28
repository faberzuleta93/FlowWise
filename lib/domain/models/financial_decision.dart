enum DecisionPriority { critical, high, medium, low }

enum DecisionCategory {
  budget, // presupuesto excedido
  credit, // deuda o tarjeta
  goal, // meta de ahorro
  liquidity, // dinero sin asignar
  achievement, // logro o reconocimiento
  momentum, // tendencia financiera
}

enum DecisionActionType {
  payCredit,
  assignMoney,
  contributeToGoal,
  reviewBudget,
  registerExpense,
  none,
}

class FinancialDecision {
  final String id;
  final String title; // corto y directo: "Paga tu tarjeta"
  final String context; // por qué: "Vence en 3 días"
  final DecisionPriority priority;
  final DecisionCategory category;
  final DecisionActionType actionType;
  final Map<String, dynamic>? actionPayload;
  final DateTime generatedAt;
  final DateTime? expiresAt;

  // Preparado para IA Premium:
  // • explanation: String (generada por IA)
  // • confidence: double
  // • alternativeActions: List<DecisionActionType>

  const FinancialDecision({
    required this.id,
    required this.title,
    required this.context,
    required this.priority,
    required this.category,
    required this.actionType,
    this.actionPayload,
    required this.generatedAt,
    this.expiresAt,
  });
}
