import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class CategorySelector extends StatelessWidget {
  final String tipo;
  final String? seleccionada;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.tipo,
    required this.seleccionada,
    required this.onSelected,
  });

  static const _gastoCategorias = [
    {'id': 'comida', 'emoji': '🍔', 'label': 'Comida'},
    {'id': 'transporte', 'emoji': '🚗', 'label': 'Transporte'},
    {'id': 'hogar', 'emoji': '🏠', 'label': 'Hogar'},
    {'id': 'salud', 'emoji': '💊', 'label': 'Salud'},
  ];

  static const _ingresoCategorias = [
    {'id': 'salario', 'emoji': '💼', 'label': 'Salario'},
    {'id': 'freelance', 'emoji': '🔧', 'label': 'Freelance'},
  ];

  @override
  Widget build(BuildContext context) {
    final cats = tipo == 'ingreso' ? _ingresoCategorias : _gastoCategorias;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categoría', style: AppTypography.label()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cats.map((c) {
            final activa = seleccionada == c['id'];
            final color =
                tipo == 'ingreso' ? AppColors.accent : AppColors.danger;
            return GestureDetector(
              onTap: () => onSelected(c['id']!),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: activa
                      ? color.withValues(alpha: 0.15)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activa ? color : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c['emoji']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(c['label']!,
                        style: AppTypography.caption(
                            color: activa ? color : AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
