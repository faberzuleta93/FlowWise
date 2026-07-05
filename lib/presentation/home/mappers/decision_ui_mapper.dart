import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/models/financial_decision.dart';
import '../../../domain/financialCore/decisions/decision_action.dart';
import '../models/decision_ui_model.dart';

/// Traduce [FinancialDecision] (dominio) a [DecisionUiModel] (presentación).
///
/// Única clase que conoce ambos mundos — espejo conceptual de
/// FinancialMovementMapper, pero hacia la UI. El Core nunca define
/// presentación; la UI nunca conoce el Core.
class DecisionUiMapper {
  const DecisionUiMapper._();

  /// Transforma la lista completa, ordenada por prioridad
  /// (critical primero). No recorta: cuántas mostrar es
  /// responsabilidad de la tarjeta.
  static List<DecisionUiModel> mapAll(List<FinancialDecision> decisions) {
    final models = decisions.map(map).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return models;
  }

  static DecisionUiModel map(FinancialDecision decision) {
    return DecisionUiModel(
      id: decision.id,
      emoji: _emojiFor(decision.type),
      title: decision.title,
      context: decision.context,
      color: _colorFor(decision.priority),
      actionLabel: _actionLabelFor(decision.action),
      sortOrder: decision.priority.index,
    );
  }

  /// Icono según el tipo semántico de la decisión.
  static String _emojiFor(DecisionType type) {
    return switch (type) {
      DecisionType.budgetExceeded => '🚨',
      DecisionType.budgetWarning => '⚠️',
      DecisionType.unassignedMoney => '💰',
      DecisionType.obligationUrgent => '🔴',
      DecisionType.obligationUpcoming => '📅',
      DecisionType.goalContribution => '🎯',
      DecisionType.momentumPositive => '📈',
      DecisionType.momentumNegative => '📉',
      DecisionType.generalInfo => 'ℹ️',
    };
  }

  /// Color de acento según prioridad.
  static Color _colorFor(DecisionPriority priority) {
    return switch (priority) {
      DecisionPriority.critical => AppColors.danger,
      DecisionPriority.high => AppColors.warning,
      DecisionPriority.medium => AppColors.gold,
      DecisionPriority.low => AppColors.accent,
    };
  }

  /// Texto del botón según la acción tipada.
  /// Switch exhaustivo: si se agrega una nueva subclase de
  /// DecisionAction, el compilador exigirá manejarla aquí.
  static String? _actionLabelFor(DecisionAction action) {
    return switch (action) {
      NoAction() => null,
      AssignMoneyAction() => 'Asignar',
      ReviewBudgetAction() => 'Revisar',
      PayCreditAction() => 'Ir al crédito',
      ContributeToGoalAction() => 'Aportar',
      RegisterMovementAction() => 'Registrar',
    };
  }
}
