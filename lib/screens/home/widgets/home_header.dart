import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class HomeHeader extends StatelessWidget {
  final String nombreUsuario;
  final bool esPremium;
  final String inicial;

  const HomeHeader({
    super.key,
    required this.nombreUsuario,
    required this.esPremium,
    required this.inicial,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buenos días,', style: AppTypography.caption()),
            Text('$nombreUsuario 👋', style: AppTypography.heading1()),
          ],
        ),
        Row(
          children: [
            _PlanBadge(esPremium: esPremium),
            const SizedBox(width: 10),
            _Avatar(inicial: inicial),
          ],
        ),
      ],
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final bool esPremium;
  const _PlanBadge({required this.esPremium});

  @override
  Widget build(BuildContext context) {
    final color = esPremium ? AppColors.gold : AppColors.premium;
    final label = esPremium ? '⭐ PREMIUM' : 'FREE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: AppTypography.micro(color: color)),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String inicial;
  const _Avatar({required this.inicial});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.accent,
      child: Text(inicial,
          style: AppTypography.heading2(color: AppColors.midnight)),
    );
  }
}
