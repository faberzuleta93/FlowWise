import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class AccountSelector extends StatelessWidget {
  final String? seleccionada;
  final ValueChanged<String> onSelected;

  const AccountSelector({
    super.key,
    required this.seleccionada,
    required this.onSelected,
  });

  static const _cuentas = [
    {'id': 'efectivo', 'emoji': '💵', 'label': 'Efectivo'},
    {'id': 'banco', 'emoji': '🏦', 'label': 'Banco'},
    {'id': 'tarjeta', 'emoji': '💳', 'label': 'Tarjeta'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cuenta', style: AppTypography.label()),
        const SizedBox(height: 8),
        Row(
          children: _cuentas.map((c) {
            final activa = seleccionada == c['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(c['id']!),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: activa
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activa ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(c['emoji']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(c['label']!,
                          style: AppTypography.micro(
                              color: activa
                                  ? AppColors.accent
                                  : AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
