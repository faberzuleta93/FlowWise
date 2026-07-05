import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Placeholder — la Vertical 2 implementa la pantalla real
/// de bienvenida con acceso a autenticación.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido a FlowWise', style: AppTypography.heading1()),
            const SizedBox(height: 8),
            Text('(pantalla en construcción — Vertical 2)',
                style: AppTypography.caption()),
          ],
        ),
      ),
    );
  }
}
