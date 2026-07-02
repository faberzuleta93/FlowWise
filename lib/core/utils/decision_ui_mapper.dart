import 'package:flutter/material.dart';
import '../../domain/models/financial_decision.dart';
import '../theme/colors.dart';

/// Convierte tipos semánticos del Core en presentación.
/// El Core nunca toca esta clase.
/// La UI nunca toca la lógica de decisiones.
class DecisionUiMapper {
  static String iconFor(DecisionType type) {
    return switch (type) {
      DecisionType.budgetExceeded => '🚨',
      DecisionType.budgetWarning => '⚠️',
      DecisionType.unassignedMoney => '💡',
      DecisionType.obligationUrgent => '🔴',
      DecisionType.obligationUpcoming => '📅',
      DecisionType.goalContribution => '🎯',
      DecisionType.momentumPositive => '↗️',
      DecisionType.momentumNegative => '↘️',
      DecisionType.generalInfo => 'ℹ️',
    };
  }

  static Color colorFor(
    DecisionType type,
    BuildContext context,
  ) {
    return switch (type) {
      DecisionType.budgetExceeded => AppColors.danger,
      DecisionType.budgetWarning => AppColors.warning,
      DecisionType.obligationUrgent => AppColors.danger,
      DecisionType.momentumNegative => AppColors.danger,
      DecisionType.momentumPositive => AppColors.accent,
      DecisionType.goalContribution => AppColors.accent,
      DecisionType.unassignedMoney => AppColors.warning,
      _ => AppColors.textSecondary,
    };
  }

  static bool isUrgent(DecisionPriority priority) =>
      priority == DecisionPriority.critical ||
      priority == DecisionPriority.high;
}
