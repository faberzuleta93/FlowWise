import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Pantalla de marca durante la resolución del estado inicial.
///
/// Completamente pasiva: sin Timer, sin Future, sin lógica.
/// AppRoot la muestra mientras AuthStatus es unknown y la
/// reemplaza cuando el estado se resuelve.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('💧', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),
            Text('FlowWise', style: AppTypography.heading1()),
            const SizedBox(height: 6),
            Text('Tu dinero, con propósito', style: AppTypography.caption()),
          ],
        ),
      ),
    );
  }
}
