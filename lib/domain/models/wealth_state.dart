class WealthState {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;

  const WealthState({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
  });

  factory WealthState.empty() => const WealthState(
        totalAssets: 0,
        totalLiabilities: 0,
        netWorth: 0,
      );
}
