import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../widgets/app_money_field.dart';
import '../../../widgets/app_primary_button.dart';
import '../../../widgets/app_card.dart';
import '../components/date_selector.dart';
import '../components/notes_field.dart';

class TransferenciaForm extends StatefulWidget {
  const TransferenciaForm({super.key});

  @override
  State<TransferenciaForm> createState() => _TransferenciaFormState();
}

class _TransferenciaFormState extends State<TransferenciaForm> {
  final _montoCtrl = TextEditingController();
  String? _cuentaOrigen;
  String? _cuentaDestino;
  DateTime _fecha = DateTime.now();
  double _monto = 0;
  bool _guardando = false;

  static const _cuentas = [
    {'id': 'efectivo', 'label': 'Efectivo', 'emoji': '💵'},
    {'id': 'banco', 'label': 'Banco', 'emoji': '🏦'},
    {'id': 'tarjeta', 'label': 'Tarjeta', 'emoji': '💳'},
  ];

  bool get _valido =>
      _monto > 0 &&
      _cuentaOrigen != null &&
      _cuentaDestino != null &&
      _cuentaOrigen != _cuentaDestino;

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('↔️ Transferencia registrada',
              style: AppTypography.bodyMedium(color: Colors.white)),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppMoneyField(
          controller: _montoCtrl,
          onChanged: (v) => setState(() => _monto = v),
        ),
        const SizedBox(height: 20),
        Text('Desde', style: AppTypography.label()),
        const SizedBox(height: 8),
        _CuentaSelector(
          cuentas: _cuentas,
          seleccionada: _cuentaOrigen,
          excluir: _cuentaDestino,
          onSelected: (c) => setState(() => _cuentaOrigen = c),
        ),
        const SizedBox(height: 16),
        // Flecha visual
        Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.arrow_downward_rounded,
                color: AppColors.warning, size: 18),
          ),
        ),
        const SizedBox(height: 16),
        Text('Hacia', style: AppTypography.label()),
        const SizedBox(height: 8),
        _CuentaSelector(
          cuentas: _cuentas,
          seleccionada: _cuentaDestino,
          excluir: _cuentaOrigen,
          onSelected: (c) => setState(() => _cuentaDestino = c),
        ),
        const SizedBox(height: 16),
        DateSelector(
          fecha: _fecha,
          onChanged: (d) => setState(() => _fecha = d),
        ),
        const SizedBox(height: 16),
        NotesField(onChanged: (_) {}),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(12),
          borderColor: AppColors.accent.withValues(alpha: 0.3),
          child: Row(
            children: [
              const Text('ℹ️'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Una transferencia no afecta tu presupuesto. Solo mueve saldo entre cuentas.',
                  style: AppTypography.caption(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          label: 'Confirmar transferencia',
          onPressed: _valido ? _guardar : null,
          isLoading: _guardando,
          icon: Icons.swap_horiz_rounded,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _CuentaSelector extends StatelessWidget {
  final List<Map<String, String>> cuentas;
  final String? seleccionada;
  final String? excluir;
  final ValueChanged<String> onSelected;

  const _CuentaSelector({
    required this.cuentas,
    required this.seleccionada,
    required this.excluir,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cuentas.where((c) => c['id'] != excluir).map((c) {
        final activa = seleccionada == c['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(c['id']!),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: activa
                    ? AppColors.warning.withValues(alpha: 0.15)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activa ? AppColors.warning : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Text(c['emoji']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(c['label']!,
                      style: AppTypography.micro(
                          color: activa
                              ? AppColors.warning
                              : AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
