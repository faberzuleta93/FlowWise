import 'financial_movement.dart';
import 'budget_category.dart';
import 'account.dart';

// Representa un movimiento en construcción
// Diseñado para crecer: cuotas, adjuntos, recurrencia, ubicación
class MovementSession {
  final MovementType type;
  final double? amount;
  final String currencyCode;
  final BudgetCategory? category;
  final Account? account;
  final Account? destinationAccount; // solo transferencias
  final DateTime date;
  final String? notes;

  const MovementSession({
    required this.type,
    this.amount,
    this.currencyCode = 'COP',
    this.category,
    this.account,
    this.destinationAccount,
    required this.date,
    this.notes,
  });

  MovementSession copyWith({
    double? amount,
    String? currencyCode,
    BudgetCategory? category,
    Account? account,
    Account? destinationAccount,
    DateTime? date,
    String? notes,
  }) {
    return MovementSession(
      type: type,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      category: category ?? this.category,
      account: account ?? this.account,
      destinationAccount: destinationAccount ?? this.destinationAccount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  bool get isValid {
    if (amount == null || amount! <= 0) return false;
    if (type != MovementType.transferencia && category == null) {
      return false;
    }
    if (account == null) return false;
    if (type == MovementType.transferencia) {
      if (destinationAccount == null) return false;
      if (account?.id == destinationAccount?.id) return false;
    }
    return true;
  }

  // Convierte la sesión en un movimiento guardable
  FinancialMovement toMovement() {
    return FinancialMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount!,
      currencyCode: currencyCode,
      categoryId: category?.id ?? 'transferencia',
      accountId: account!.id,
      destinationAccountId: destinationAccount?.id,
      date: date,
      notes: notes,
      status: MovementStatus.saved,
      createdAt: DateTime.now(),
    );
  }
}
