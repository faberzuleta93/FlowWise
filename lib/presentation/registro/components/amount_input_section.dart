import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class AmountInputSection extends StatefulWidget {
  final double? initialAmount;
  final String currencyCode;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<String> onCurrencyChanged;

  const AmountInputSection({
    super.key,
    this.initialAmount,
    required this.currencyCode,
    required this.onAmountChanged,
    required this.onCurrencyChanged,
  });

  @override
  State<AmountInputSection> createState() => _AmountInputSectionState();
}

class _AmountInputSectionState extends State<AmountInputSection> {
  late final TextEditingController _ctrl;

  static const _currencies = [
    {'code': 'COP', 'symbol': '\$', 'label': 'Peso colombiano'},
    {'code': 'USD', 'symbol': 'US\$', 'label': 'Dólar americano'},
    {'code': 'EUR', 'symbol': '€', 'label': 'Euro'},
    {'code': 'MXN', 'symbol': 'MX\$', 'label': 'Peso mexicano'},
    {'code': 'ARS', 'symbol': 'AR\$', 'label': 'Peso argentino'},
    {'code': 'CLP', 'symbol': 'CL\$', 'label': 'Peso chileno'},
    {'code': 'PEN', 'symbol': 'S/', 'label': 'Sol peruano'},
    {'code': 'BRL', 'symbol': 'R\$', 'label': 'Real brasileño'},
  ];

  String get _symbol => _currencies.firstWhere(
        (c) => c['code'] == widget.currencyCode,
        orElse: () => _currencies.first,
      )['symbol']!;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? widget.initialAmount!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Selecciona la moneda', style: AppTypography.heading2()),
          const SizedBox(height: 12),
          ..._currencies.map((c) => ListTile(
                leading: Text(c['symbol']!,
                    style: AppTypography.heading2(color: AppColors.accent)),
                title: Text(c['code']!, style: AppTypography.bodyMedium()),
                subtitle: Text(c['label']!, style: AppTypography.caption()),
                trailing: c['code'] == widget.currencyCode
                    ? const Icon(Icons.check_rounded, color: AppColors.accent)
                    : null,
                onTap: () {
                  widget.onCurrencyChanged(c['code']!);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Selector de moneda
          GestureDetector(
            onTap: _showCurrencyPicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.currencyCode,
                    style: AppTypography.label(color: AppColors.accent)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.accent, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Campo de monto
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_symbol,
                  style:
                      AppTypography.heading1(color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              Flexible(
                child: IntrinsicWidth(
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      _MaxDecimalsFormatter(),
                    ],
                    style: AppTypography.display(color: AppColors.accent),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: AppTypography.display(color: AppColors.border),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) {
                      final parsed = double.tryParse(v) ?? 0;
                      widget.onAmountChanged(parsed);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaxDecimalsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length > 2) return oldValue;
      if (parts[1].length > 2) return oldValue;
    }
    return newValue;
  }
}
