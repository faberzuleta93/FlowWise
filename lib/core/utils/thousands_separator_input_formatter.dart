import 'package:flutter/services.dart';

/// Formatea montos con separador de miles EN VIVO mientras el
/// usuario escribe: 1000000 → 1.000.000 (convención colombiana:
/// punto como separador de miles).
///
/// Ver los dígitos agrupados ayuda a registrar montos correctos —
/// deuda de UX elevada desde la validación del Sprint 2.
///
/// Reutilizable: campo de monto en registro de movimientos y campo
/// de ingreso en el perfil financiero. Solo maneja enteros (los
/// montos en COP no usan decimales en la práctica).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const String _separator = ',';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Solo dígitos: descarta cualquier otro carácter (incluidos
    // separadores previos, para reformatear desde cero).
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Evita montos absurdos por pulsación accidental (>15 dígitos).
    if (digits.length > 15) return oldValue;

    final formatted = _group(digits);

    return TextEditingValue(
      text: formatted,
      // Cursor siempre al final: comportamiento estándar de los
      // campos de monto (el usuario escribe, no edita en medio).
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _group(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(_separator);
      }
    }
    return buffer.toString();
  }
}
