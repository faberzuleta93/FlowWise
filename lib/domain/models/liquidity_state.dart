class LiquidityState {
  final double availableToday;
  final double unassignedMoney;
  final Map<String, double> balanceByAccount;

  const LiquidityState({
    required this.availableToday,
    required this.unassignedMoney,
    required this.balanceByAccount,
  });

  factory LiquidityState.empty() => const LiquidityState(
        availableToday: 0,
        unassignedMoney: 0,
        balanceByAccount: {},
      );
}
