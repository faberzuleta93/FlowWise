import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

class AppMoneyField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<double>? onChanged;
  final String? hint;

  const AppMoneyField({
    super.key,
    required this.controller,
    this.onChanged,
    this.hint,
  });

  @override
  State<AppMoneyField> createState() => _AppMoneyFieldState();
}

class _AppMoneyFieldState extends State<AppMoneyField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text('VALOR', style: AppTypography.label()),
          const SizedBox(height: 8),
          TextField(
            controller: widget.controller,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            style: AppTypography.display(color: AppColors.accent),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint ?? '\$0',
              hintStyle: AppTypography.display(color: AppColors.border),
              prefixText: '\$ ',
              prefixStyle:
                  AppTypography.heading2(color: AppColors.textSecondary),
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v) ?? 0;
              widget.onChanged?.call(parsed);
            },
          ),
        ],
      ),
    );
  }
}
