import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

class AppProgressIndicator extends StatelessWidget {
  final double value;
  final Color? color;
  final String? label;
  final String? trailingLabel;

  const AppProgressIndicator({
    super.key,
    required this.value,
    this.color,
    this.label,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppColors.accent;
    final clamped = value.clamp(0.0, 1.0);

    return Column(
      children: [
        if (label != null || trailingLabel != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null) Text(label!, style: AppTypography.micro()),
              if (trailingLabel != null)
                Text(trailingLabel!,
                    style: AppTypography.micro(color: barColor)),
            ],
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 7,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
