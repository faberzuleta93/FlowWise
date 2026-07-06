import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../domain/repositories/authentication_repository.dart';

/// Pantalla de perfil.
///
/// Por ahora solo contiene el cierre de sesión. Regla 5: no navega
/// tras el signOut — AppRoot detecta el cambio y muestra Welcome.
class PerfilScreen extends StatelessWidget {
  final AuthenticationRepository authRepository;

  const PerfilScreen({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Perfil', style: AppTypography.heading1()),
              const SizedBox(height: 8),
              Text('(pantalla en construcción)',
                  style: AppTypography.caption()),
              const Spacer(),
              GestureDetector(
                onTap: () => authRepository.signOut(),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text('Cerrar sesión',
                        style:
                            AppTypography.bodyMedium(color: AppColors.danger)),
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
