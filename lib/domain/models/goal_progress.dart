class GoalProgress {
  final String id;
  final String name;
  final String emoji;
  final double target;
  final double current;
  final double percentage;
  final DateTime? targetDate;

  const GoalProgress({
    required this.id,
    required this.name,
    required this.emoji,
    required this.target,
    required this.current,
    required this.percentage,
    this.targetDate,
  });
}
