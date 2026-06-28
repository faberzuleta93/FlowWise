import '../../../widgets/card_base.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';

class DailySpendingCard extends StatelessWidget {
  final double disponibleHoy;
  final double sinAsignar;

  const DailySpendingCard({
    super.key,
    required this.disponibleHoy,
    required this.sinAsignar,
  });

  @override
  Widget build(BuildContext context) {
    return CardBase(
      pregunta: '¿Tengo dinero?',
      child: Column(
        children: [
          _MoneyRow(
            label: 'Disponible hoy',
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
        Text(label, style: AppTypography.caption()),
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
