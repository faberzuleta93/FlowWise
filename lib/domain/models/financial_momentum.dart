enum MomentumDirection {
  improving, // ↗ Mejorando
  stable, // → Estable
  declining, // ↘ Empeorando
}

class FinancialMomentum {
  final MomentumDirection direction;
  final double balanceChangeVsLastMonth; // +/- en pesos
  final double savingsRateChangeVsLastMonth; // +/- en %
  final String label; // "Mejorando", "Estable", "Empeorando"
  final String emoji; // ↗ → ↘

  // Preparado para V2:
  // • trendData: List<double> (últimos 6 meses)
  // • bestMonth
  // • worstMonth

  const FinancialMomentum({
    required this.direction,
    required this.balanceChangeVsLastMonth,
    required this.savingsRateChangeVsLastMonth,
    required this.label,
    required this.emoji,
  });

  factory FinancialMomentum.initial() => const FinancialMomentum(
        direction: MomentumDirection.stable,
        balanceChangeVsLastMonth: 0,
        savingsRateChangeVsLastMonth: 0,
        label: 'Estable',
        emoji: '→',
      );
}
