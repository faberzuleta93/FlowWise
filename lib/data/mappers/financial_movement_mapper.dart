import '../../domain/models/financial_movement.dart';

/// Traduce entre [FinancialMovement] (dominio) y
/// Map<String, dynamic> (formato de persistencia).
///
/// Esta es la única clase del proyecto que conoce ambos formatos.
/// El dominio nunca serializa. La capa de datos nunca conoce
/// la lógica de negocio del movimiento.
class FinancialMovementMapper {
  const FinancialMovementMapper._();

  static Map<String, dynamic> toMap(FinancialMovement movement) {
    return {
      'id': movement.id,
      'type': movement.type.name,
      'amount': movement.amount,
      'currencyCode': movement.currencyCode,
      'categoryId': movement.categoryId,
      'accountId': movement.accountId,
      'destinationAccountId': movement.destinationAccountId,
      'date': movement.date.toIso8601String(),
      'notes': movement.notes,
      'status': movement.status.name,
      'createdAt': movement.createdAt.toIso8601String(),
    };
  }

  static FinancialMovement fromMap(Map<String, dynamic> map) {
    return FinancialMovement(
      id: map['id'] as String,
      type: MovementType.values.byName(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      currencyCode: map['currencyCode'] as String,
      categoryId: map['categoryId'] as String,
      accountId: map['accountId'] as String,
      destinationAccountId: map['destinationAccountId'] as String?,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      status: MovementStatus.values.byName(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
