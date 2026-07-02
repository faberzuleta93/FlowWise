import '../../../widgets/card_base.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../domain/models/home_view_model.dart';
import '../../../core/utils/formatters.dart';

class RecentMovementsCard extends StatelessWidget {
  final List<MovimientoReciente> movimientos;

  const RecentMovementsCard({
    super.key,
    required this.movimientos,
  });

  @override
  Widget build(BuildContext context) {
    return CardBase(
      pregunta: 'Movimientos de hoy',
      accion: Text('Ver todo',
          style: AppTypography.caption(color: AppColors.accent)),
      child: Column(
        children: movimientos
            .asMap()
            .entries
            .map((e) => _MovimientoRow(
                  item: e.value,
                  isLast: e.key == movimientos.length - 1,
                ))
            .toList(),
      ),
    );
  }
}

class _MovimientoRow extends StatelessWidget {
  final MovimientoReciente item;
  final bool isLast;

  const _MovimientoRow({
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final esPositivo = item.monto > 0;
    final color = item.esTransferencia
        ? AppColors.warning
        : esPositivo
            ? AppColors.accent
            : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nombre, style: AppTypography.bodyMedium()),
                Text(item.subtitulo, style: AppTypography.caption()),
              ],
            ),
          ),
          Text(
            '${esPositivo && !item.esTransferencia ? '+' : ''}${formatCurrency(item.monto)}',
            style: AppTypography.heading3(color: color),
          ),
        ],
      ),
    );
  }
}
