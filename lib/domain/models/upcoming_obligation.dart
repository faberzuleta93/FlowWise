enum ObligationType { creditCard, formalLoan, informalLoan }

enum ObligationUrgency { urgent, upcoming, future }

class UpcomingObligation {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final int daysUntilDue;
  final ObligationType type;
  final ObligationUrgency urgency;

  const UpcomingObligation({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.daysUntilDue,
    required this.type,
    required this.urgency,
  });
}
