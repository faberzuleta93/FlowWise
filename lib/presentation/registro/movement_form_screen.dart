import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../domain/models/financial_movement.dart';
import '../../domain/models/budget_category.dart';
import '../../domain/models/account.dart';
import '../../widgets/app_primary_button.dart';
import 'movement_form_viewmodel.dart' as vm_lib;
import 'components/amount_input_section.dart';
import 'components/category_grid.dart';
import 'components/account_bottom_sheet.dart';
import 'components/date_selector.dart';
import 'components/notes_field.dart';

class MovementFormScreen extends StatefulWidget {
  final vm_lib.MovementFormViewModel viewModel;

  const MovementFormScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<MovementFormScreen> createState() => _MovementFormScreenState();
}

class _MovementFormScreenState extends State<MovementFormScreen> {
  vm_lib.MovementFormViewModel get _vm => widget.viewModel;

  List<BudgetCategory> get _categories {
    if (_vm.type == MovementType.ingreso) {
      return DefaultCategories.ingresos;
    }
    return DefaultCategories.gastos;
  }

  Future<void> _onSave() async {
    final success = await _vm.save();
    if (success && mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _labelExito,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.surfaceLight,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String get _labelExito => switch (_vm.type) {
        MovementType.ingreso => '✅ Ingreso registrado',
        MovementType.gasto => '✅ Gasto registrado',
        MovementType.transferencia => '↔️ Transferencia registrada',
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AmountInputSection(
                initialAmount: _vm.session.amount,
                currencyCode: _vm.session.currencyCode,
                onAmountChanged: _vm.updateAmount,
                onCurrencyChanged: _vm.updateCurrency,
              ),
              const SizedBox(height: 20),
              if (_vm.type != MovementType.transferencia) ...[
                CategoryGrid(
                  movementType: _vm.type,
                  categories: _categories,
                  selected: _vm.session.category,
                  onSelected: _vm.updateCategory,
                ),
                const SizedBox(height: 20),
              ],
              _AccountSelector(
                label:
                    _vm.type == MovementType.transferencia ? 'Desde' : 'Cuenta',
                selected: _vm.session.account,
                onTap: () => AccountBottomSheet.show(
                  context: context,
                  accounts: DefaultAccounts.all,
                  selected: _vm.session.account,
                  excluded: _vm.session.destinationAccount,
                  onSelected: _vm.updateAccount,
                ),
              ),
              const SizedBox(height: 12),
              if (_vm.type == MovementType.transferencia) ...[
                _TransferArrow(),
                const SizedBox(height: 12),
                _AccountSelector(
                  label: 'Hacia',
                  selected: _vm.session.destinationAccount,
                  onTap: () => AccountBottomSheet.show(
                    context: context,
                    accounts: DefaultAccounts.all,
                    selected: _vm.session.destinationAccount,
                    excluded: _vm.session.account,
                    onSelected: _vm.updateDestinationAccount,
                  ),
                ),
                const SizedBox(height: 12),
                const _TransferInfoBanner(),
                const SizedBox(height: 12),
              ],
              DateSelector(
                fecha: _vm.session.date,
                onChanged: _vm.updateDate,
              ),
              const SizedBox(height: 12),
              NotesField(onChanged: _vm.updateNotes),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: _labelGuardar,
                onPressed: _vm.isValid ? _onSave : null,
                isLoading: _vm.isLoading,
                icon: Icons.check_rounded,
              ),
              if (_vm.state == vm_lib.FormState.error) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: _vm.errorMessage ?? ''),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String get _labelGuardar => switch (_vm.type) {
        MovementType.ingreso => 'Guardar ingreso',
        MovementType.gasto => 'Guardar gasto',
        MovementType.transferencia => 'Confirmar transferencia',
      };
}

class _AccountSelector extends StatelessWidget {
  final String label;
  final Account? selected;
  final VoidCallback onTap;

  const _AccountSelector({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected != null
                ? AppColors.accent.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              Text(selected!.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
            ] else
              const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label, style: AppTypography.caption()),
            ),
            Text(
              selected?.name ?? 'Seleccionar',
              style: AppTypography.bodyMedium(
                color:
                    selected != null ? AppColors.accent : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TransferArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: const Icon(
          Icons.arrow_downward_rounded,
          color: AppColors.warning,
          size: 18,
        ),
      ),
    );
  }
}

class _TransferInfoBanner extends StatelessWidget {
  const _TransferInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Una transferencia no afecta tu presupuesto. Solo mueve saldo entre cuentas.',
              style: AppTypography.caption(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Text(message, style: AppTypography.caption(color: AppColors.danger)),
        ],
      ),
    );
  }
}
