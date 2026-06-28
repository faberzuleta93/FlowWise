enum HealthLevel {
  critical, // 0-20
  low, // 21-40
  moderate, // 41-60
  good, // 61-80
  excellent, // 81-100
}

enum HealthTrend {
  improving, // ↗
  stable, // →
  declining, // ↘
}

class FinancialHealth {
  final double score; // 0.0 a 100.0
  final HealthLevel level;
  final HealthTrend trend;
  final DateTime lastUpdated;

  // Preparado para Sprint de gamificación:
  // • streakDays
  // • achievementsUnlocked
  // • weeklyChange
  // • monthlyChange

  const FinancialHealth({
    required this.score,
    required this.level,
    required this.trend,
    required this.lastUpdated,
  });

  // Estado inicial — sin datos aún
  factory FinancialHealth.initial() => FinancialHealth(
        score: 0,
        level: HealthLevel.moderate,
        trend: HealthTrend.stable,
        lastUpdated: DateTime.now(),
      );
}
