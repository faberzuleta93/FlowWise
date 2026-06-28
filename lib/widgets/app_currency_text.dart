import 'package:flutter/material.dart';
import '../core/theme/typography.dart';
import '../core/theme/colors.dart';

enum CurrencySize { small, medium, large, display }

class AppCurrencyText extends StatelessWidget {
  final double valor;
  final CurrencySize size;
  final Color? color;
  final bool mostrarSigno;

  const AppCurrencyText({
    super.key,
    required this.valor,
    this.size = CurrencySize.medium,
    this.color,
    this.mostrarSigno = false,
  });

  String get _formatted {
    final abs = valor.abs();
    final str = abs.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    final signo =
        mostrarSigno ? (valor >= 0 ? '+' : '-') : (valor < 0 ? '-' : '');
    return '$signo\$$str';
  }

  TextStyle get _style {
    final c = color ?? (valor >= 0 ? AppColors.accent : AppColors.danger);
    switch (size) {
      case CurrencySize.small:
        return AppTypography.caption(color: c);
      case CurrencySize.medium:
        return AppTypography.bodyMedium(color: c);
      case CurrencySize.large:
        return AppTypography.heading2(color: c);
      case CurrencySize.display:
        return AppTypography.display(color: c);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formatted, style: _style);
  }
}
