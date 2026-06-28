import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../domain/models/financial_movement.dart';
import '../../data/repositories/memory_movement_repository.dart';
import '../../presentation/registro/movement_form_viewmodel.dart';
import '../../presentation/registro/movement_form_screen.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  // Repositorio compartido — en el futuro vendrá de un Provider
  static final _repository = MemoryMovementRepository();

  void _abrirFormulario(BuildContext context, MovementType type) {
    final vm = MovementFormViewModel(
      repository: _repository,
      type: type,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.97,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(_titulo(type), style: AppTypography.heading2()),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: MovementFormScreen(viewModel: vm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titulo(MovementType type) => switch (type) {
        MovementType.ingreso => 'Registrar ingreso',
        MovementType.gasto => 'Registrar gasto',
        MovementType.transferencia => 'Transferencia entre cuentas',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('¿Qué quieres registrar?', style: AppTypography.heading2()),
          const SizedBox(height: 6),
          Text('Selecciona el tipo de movimiento',
              style: AppTypography.caption()),
          const SizedBox(height: 24),
          _TipoButton(
            emoji: '📈',
            label: 'Registrar ingreso',
            sublabel: 'Salario, freelance, otros',
            color: AppColors.accent,
            onTap: () {
              Navigator.pop(context);
              _abrirFormulario(context, MovementType.ingreso);
            },
          ),
          const SizedBox(height: 10),
          _TipoButton(
            emoji: '📉',
            label: 'Registrar gasto',
            sublabel: 'Comida, transporte, hogar...',
            color: AppColors.danger,
            onTap: () {
              Navigator.pop(context);
              _abrirFormulario(context, MovementType.gasto);
            },
          ),
          const SizedBox(height: 10),
          _TipoButton(
            emoji: '↔️',
            label: 'Transferencia entre cuentas',
            sublabel: 'No afecta tu presupuesto',
            color: AppColors.warning,
            onTap: () {
              Navigator.pop(context);
              _abrirFormulario(context, MovementType.transferencia);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _TipoButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _TipoButton({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.bodyMedium(color: color)),
                    Text(sublabel, style: AppTypography.caption()),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
