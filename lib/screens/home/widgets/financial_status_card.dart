import '../../../widgets/card_base.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';

class FinancialStatusCard extends StatelessWidget {
  final double ingresosMes;
  final double gastosMes;
  final double balance;

  const FinancialStatusCard({
    super.key,
    required this.ingresosMes,
    required this.gastosMes,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return CardBase(
      pregunta: '¿Cómo estoy?',
      child: Row(
        children: [
          _StatItem(
            label: 'Ingresos',
            valor: ingresosMes,
            color: AppColors.accent,
            icono: '📈',
          ),
          _Divider(),
          _StatItem(
            label: 'Gastos',
            valor: gastosMes,
            color: AppColors.danger,
            icono: '📉',
          ),
          _Divider(),
          _StatItem(
            label: 'Balance',
            valor: balance,
            color: balance >= 0 ? AppColors.accent : AppColors.danger,
            icono: balance >= 0 ? '✅' : '⚠️',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double valor;
  final Color color;
  final String icono;

  const _StatItem({
    required this.label,
    required this.valor,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icono, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(formatCurrency(valor),
              style: AppTypography.bodyMedium(color: color),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.micro(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.border,
    );
  }
}
