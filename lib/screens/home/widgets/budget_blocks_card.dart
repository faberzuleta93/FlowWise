import '../../../widgets/card_base.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../domain/models/home_view_model.dart';
import '../../../domain/models/budget_state.dart';
import '../../../core/utils/formatters.dart';

class BudgetBlocksCard extends StatelessWidget {
  final List<BloquePresupuesto> bloques;

  /// Origen del presupuesto: la UI declara honestamente si los
  /// montos vienen del plan del usuario o de sus ingresos
  /// registrados (ADR-0002, principio 3: nunca caja negra).
  final BudgetBasis basis;

  const BudgetBlocksCard({
    super.key,
    required this.bloques,
    required this.basis,
  });

  bool get _esPlan => basis == BudgetBasis.declaredPlan;

  @override
  Widget build(BuildContext context) {
    return CardBase(
      pregunta: '¿Voy bien este mes?',
      child: Column(
        children:
            bloques.map((b) => _BloqueRow(bloque: b, esPlan: _esPlan)).toList(),
      ),
    );
  }
}

class _BloqueRow extends StatelessWidget {
  final BloquePresupuesto bloque;
  final bool esPlan;

  const _BloqueRow({required this.bloque, required this.esPlan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          // Fila 1: color dot + nombre + porcentaje + mensaje
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: bloque.mensajeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('${bloque.emoji} ${bloque.nombre}',
                  style: AppTypography.bodyMedium()),
              const Spacer(),
              Text(
                '${(bloque.porcentaje * 100).toStringAsFixed(0)}%',
                style: AppTypography.caption(color: bloque.mensajeColor),
              ),
              const SizedBox(width: 8),
              _MensajeBadge(bloque: bloque),
            ],
          ),
          const SizedBox(height: 6),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: bloque.porcentaje.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(bloque.mensajeColor),
            ),
          ),
          const SizedBox(height: 4),
          // Fila 2: monto usado vs presupuesto/plan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Usado: ${formatCurrency(bloque.gasto)}',
                  style: AppTypography.micro()),
              Text(
                  '${esPlan ? 'Plan' : 'Presup.'}: ${formatCurrency(bloque.max)}',
                  style: AppTypography.micro()),
            ],
          ),
        ],
      ),
    );
  }
}

class _MensajeBadge extends StatelessWidget {
  final BloquePresupuesto bloque;
  const _MensajeBadge({required this.bloque});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bloque.mensajeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(bloque.mensaje,
          style: AppTypography.micro(color: bloque.mensajeColor)),
    );
  }
}
