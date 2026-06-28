String formatCurrency(double valor) {
  final abs = valor.abs();
  final formatted = abs.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  return '\$$formatted';
}
