import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../state/movement_ownership_notifier.dart';
import '../../state/user_profile_notifier.dart';

/// Decisión 4: qué hacer con los movimientos preexistentes en el
/// dispositivo al iniciar sesión. Regla 5: no navega; AppRoot
/// reacciona cuando el estado pasa a resolved.
class OwnershipDecisionScreen extends StatelessWidget {
  final MovementOwnershipNotifier ownershipNotifier;
  final UserProfileNotifier userProfileNotifier;

  const OwnershipDecisionScreen({
    super.key,
    required this.ownershipNotifier,
    required this.userProfileNotifier,
  });

  Future<void> _confirmarBorrado(BuildContext context) async {
    final owner = userProfileNotifier.profile;
    if (owner == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Estás seguro de empezar desde cero?',
            style: AppTypography.heading2()),
        content: Text(
          'Se eliminarán todos los registros guardados hasta ahora '
          'en este dispositivo.',
          style: AppTypography.caption(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar',
                style:
                    AppTypography.bodyMedium(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sí, eliminar',
                style: AppTypography.bodyMedium(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await ownershipNotifier.discard(owner);
    }
  }

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
              const Text('📂', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 20),
              Text('Encontramos movimientos\nen este dispositivo',
                  style: AppTypography.heading1()),
              const SizedBox(height: 10),
              Text(
                '¿Quieres conservarlos en tu cuenta o prefieres '
                'empezar desde cero?',
                style: AppTypography.caption(),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final owner = userProfileNotifier.profile;
                  if (owner != null) ownershipNotifier.claim(owner);
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Conservarlos',
                        style: AppTypography.bodyMedium(
                            color: AppColors.midnight)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () => _confirmarBorrado(context),
                  child: Text('Empezar desde cero',
                      style: AppTypography.bodyMedium(color: AppColors.danger)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
