import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../auth/auth_screen.dart';

/// Bienvenida: marca + propuesta de valor + entrada al flujo de auth.
/// El push a AuthScreen es navegación DENTRO del flujo de bienvenida,
/// permitida por la Regla 5 (no decide flujo principal).
class WelcomeScreen extends StatelessWidget {
  final AuthenticationRepository authRepository;

  const WelcomeScreen({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('💧', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(height: 24),
              Text('FlowWise', style: AppTypography.heading1()),
              const SizedBox(height: 10),
              Text(
                'No solo registres tu dinero.\nDecide qué hacer con él.',
                style: AppTypography.heading2(color: AppColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AuthScreen(authRepository: authRepository),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Comenzar',
                        style: AppTypography.bodyMedium(
                            color: AppColors.midnight)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
