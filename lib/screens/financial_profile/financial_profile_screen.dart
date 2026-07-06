import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../domain/models/financial_profile.dart';
import '../../presentation/profile/financial_profile_form_viewmodel.dart';
import '../../state/financial_profile_notifier.dart';

/// Perfil financiero inicial. Diseño guiado: el usuario puede
/// completarlo o posponerlo — FlowWise guía, no obliga.
/// Regla 5: no navega; AppRoot reacciona al cambio de estado.
class FinancialProfileScreen extends StatefulWidget {
  final FinancialProfileNotifier profileNotifier;

  const FinancialProfileScreen({super.key, required this.profileNotifier});

  @override
  State<FinancialProfileScreen> createState() => _FinancialProfileScreenState();
}

class _FinancialProfileScreenState extends State<FinancialProfileScreen> {
  late final FinancialProfileFormViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = FinancialProfileFormViewModel(notifier: widget.profileNotifier);
  }

  @override
  void dispose() {
    _vm.dispose(); // Regla 4: esta pantalla es propietaria del VM.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Text('Cuéntanos de tus finanzas',
                      style: AppTypography.heading1()),
                  const SizedBox(height: 6),
                  Text(
                    'Esto nos ayuda a darte mejores recomendaciones.\nPuedes omitirlo si prefieres.',
                    style: AppTypography.caption(),
                  ),
                  const SizedBox(height: 28),
                  Text('Ingreso mensual aproximado',
                      style: AppTypography.caption()),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: _vm.updateIncome,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTypography.bodyMedium(),
                    decoration: _inputDecoration('Ej: 3000000'),
                  ),
                  const SizedBox(height: 20),
                  Text('¿Cada cuánto recibes tu pago?',
                      style: AppTypography.caption()),
                  const SizedBox(height: 10),
                  _FrequencySelector(
                    selected: _vm.payFrequency,
                    onChanged: _vm.updateFrequency,
                  ),
                  if (_vm.asksPayDay) ...[
                    const SizedBox(height: 20),
                    Text('¿Qué día del mes te pagan? (1-31)',
                        style: AppTypography.caption()),
                    const SizedBox(height: 6),
                    TextField(
                      onChanged: _vm.updatePayDay,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTypography.bodyMedium(),
                      decoration: _inputDecoration('Ej: 30'),
                    ),
                  ],
                  if (_vm.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(_vm.errorMessage!,
                        style: AppTypography.caption(color: AppColors.danger)),
                  ],
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _vm.isSaving ? null : _vm.complete,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.accent
                            .withValues(alpha: _vm.isSaving ? 0.6 : 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _vm.isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.midnight),
                              )
                            : Text('Continuar',
                                style: AppTypography.bodyMedium(
                                    color: AppColors.midnight)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: GestureDetector(
                      onTap: _vm.isSaving ? null : _vm.postpone,
                      child: Text('Lo haré después',
                          style: AppTypography.bodyMedium(
                              color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  final PayFrequency selected;
  final ValueChanged<PayFrequency> onChanged;

  const _FrequencySelector({required this.selected, required this.onChanged});

  static const _labels = {
    PayFrequency.weekly: 'Semanal',
    PayFrequency.biweekly: 'Quincenal',
    PayFrequency.monthly: 'Mensual',
    PayFrequency.irregular: 'Irregular',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PayFrequency.values.map((f) {
        final activo = f == selected;
        return GestureDetector(
          onTap: () => onChanged(f),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: activo
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: activo ? AppColors.accent : AppColors.border),
            ),
            child: Text(_labels[f]!,
                style: AppTypography.bodyMedium(
                    color: activo ? AppColors.accent : AppColors.textPrimary)),
          ),
        );
      }).toList(),
    );
  }
}
