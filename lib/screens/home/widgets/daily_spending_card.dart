import '../../../widgets/card_base.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';

class DailySpendingCard extends StatelessWidget {
  final double disponibleHoy;
  final double sinAsignar;

  /// Días hasta el próximo ingreso esperado. Null → sin proyección
  /// (el horizonte es el fin de mes y no se menciona el pago).
  final int? diasHastaPago;

  const DailySpendingCard({
    super.key,
    required this.disponibleHoy,
    required this.sinAsignar,
    this.diasHastaPago,
  });

  String get _labelDisponible {
    final dias = diasHastaPago;
    if (dias == null) return 'Disponible hoy';
    if (dias == 0) return 'Disponible hoy · tu pago es hoy';
    return 'Disponible hoy · $dias días para tu pago';
  }

  @override
  Widget build(BuildContext context) {
    return CardBase(
      pregunta: '¿Tengo dinero?',
      child: Column(
        children: [
          _MoneyRow(
            label: _labelDisponible,
            valor: disponibleHoy,
            color: AppColors.accent,
            grande: true,
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          _MoneyRow(
            label: 'Sin asignar este mes',
            valor: sinAsignar,
            color: sinAsignar >= 0 ? AppColors.warning : AppColors.danger,
            grande: false,
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double valor;
  final Color color;
  final bool grande;

  const _MoneyRow({
    required this.label,
    required this.valor,
    required this.color,
    required this.grande,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: AppTypography.caption())),
        Text(
          formatCurrency(valor),
          style: grande
              ? AppTypography.heading2(color: color)
              : AppTypography.bodyMedium(color: color),
        ),
      ],
    );
  }
}
