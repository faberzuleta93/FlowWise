import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

class AppBottomSheet extends StatelessWidget {
  final String? titulo;
  final Widget child;
  final double initialSize;

  const AppBottomSheet({
    super.key,
    this.titulo,
    required this.child,
    this.initialSize = 0.6,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? titulo,
    double initialSize = 0.6,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheet(
        titulo: titulo,
        initialSize: initialSize,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (titulo != null) ...[
                const SizedBox(height: 16),
                Text(titulo!, style: AppTypography.heading2()),
              ],
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
