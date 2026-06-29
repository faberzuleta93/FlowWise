class MonthSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final double savingsRate;

  const MonthSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.savingsRate,
  });

  factory MonthSummary.empty() => const MonthSummary(
        totalIncome: 0,
        totalExpenses: 0,
        balance: 0,
        savingsRate: 0,
      );
}
