import '../../domain/models/financial_profile.dart';

/// Traduce entre [FinancialProfile] (dominio) y
/// Map<String, dynamic> (formato de persistencia).
class FinancialProfileMapper {
  const FinancialProfileMapper._();

  static Map<String, dynamic> toMap(FinancialProfile profile) {
    return {
      'monthlyIncome': profile.monthlyIncome,
      'payFrequency': profile.payFrequency.name,
      'payDay': profile.payDay,
      'completed': profile.completed,
      'offeredAt': profile.offeredAt?.toIso8601String(),
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
    };
  }

  static FinancialProfile fromMap(Map<String, dynamic> map) {
    return FinancialProfile(
      monthlyIncome: (map['monthlyIncome'] as num?)?.toDouble(),
      payFrequency: PayFrequency.values.byName(map['payFrequency'] as String),
      payDay: map['payDay'] as int?,
      completed: map['completed'] as bool,
      offeredAt: map['offeredAt'] == null
          ? null
          : DateTime.parse(map['offeredAt'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
