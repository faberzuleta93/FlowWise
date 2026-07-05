import 'package:flutter/material.dart';
import '../../../widgets/card_base.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../presentation/home/models/decision_ui_model.dart';

/// Tarjeta "¿Qué debo hacer ahora?" — la cuarta pregunta del Home.
///
/// Renderiza [DecisionUiModel] ya mapeados por DecisionUiMapper.
/// No conoce el Core Financiero ni contiene lógica de negocio:
/// solo recorta a tres elementos y pinta.
class DecisionsCard extends StatelessWidget {
  /// Decisiones ya ordenadas por prioridad (ver DecisionUiMapper.mapAll).
  final List<DecisionUiModel> decisions;

  /// Callback de la acción principal de cada decisión.
  /// Recibe el id de la decisión tocada.
  // TODO(Sprint-3): conectar con navegación real según la acción.
  final void Function(String decisionId) onActionTap;

  const DecisionsCard({
    super.key,
    required this.decisions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibles = decisions.take(3).toList();

    return CardBase(
      pregunta: '¿Qué debo hacer ahora?',
      child: visibles.isEmpty
          ? const _AllClear()
          : Column(
              children: visibles
                  .asMap()
                  .entries
                  .map((e) => _DecisionRow(
                        model: e.value,
                        isLast: e.key == visibles.length - 1,
                        onActionTap: () => onActionTap(e.value.id),
                      ))
                  .toList(),
            ),
    );
  }
}

class _DecisionRow extends StatelessWidget {
  final DecisionUiModel model;
  final bool isLast;
  final VoidCallback onActionTap;

  const _DecisionRow({
    required this.model,
    required this.isLast,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.title, style: AppTypography.bodyMedium()),
                const SizedBox(height: 2),
                Text(model.context, style: AppTypography.caption()),
              ],
            ),
          ),
          if (model.actionLabel != null) ...[
            const SizedBox(width: 10),
            _ActionChip(
              label: model.actionLabel!,
              color: model.color,
              onTap: onActionTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(label, style: AppTypography.micro(color: color)),
      ),
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Todo en orden por ahora',
                    style: AppTypography.bodyMedium()),
                Text('No hay acciones pendientes. Sigue así.',
                    style: AppTypography.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
