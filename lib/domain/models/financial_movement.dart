enum MovementType { ingreso, gasto, transferencia }

enum MovementStatus { draft, saved, synced, error }

class FinancialMovement {
  final String id;
  final MovementType type;
  final double amount;
  final String currencyCode;
  final String categoryId;
  final String accountId;
  final String? destinationAccountId; // solo transferencias
  final DateTime date;
  final String? notes;
  final MovementStatus status;
  final DateTime createdAt;

  const FinancialMovement({
    required this.id,
    required this.type,
    required this.amount,
    required this.currencyCode,
    required this.categoryId,
    required this.accountId,
    this.destinationAccountId,
    required this.date,
    this.notes,
    this.status = MovementStatus.draft,
    required this.createdAt,
  });

  // Preparado para crecer: cuotas, adjuntos, ubicación, recurrencia
  FinancialMovement copyWith({
    String? id,
    MovementType? type,
    double? amount,
    String? currencyCode,
    String? categoryId,
    String? accountId,
    String? destinationAccountId,
    DateTime? date,
    String? notes,
    MovementStatus? status,
  }) {
    return FinancialMovement(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
