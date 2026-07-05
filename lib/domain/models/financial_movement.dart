/// Tipo de movimiento financiero registrado por el usuario.
enum MovementType { ingreso, gasto, transferencia }

/// Estado de sincronización del movimiento.
/// draft: aún no guardado. saved: persistido localmente.
/// synced: respaldado en la nube. error: falló al guardar o sincronizar.
enum MovementStatus { draft, saved, synced, error }

/// Representa la unidad básica del Core Financiero de FlowWise.
///
/// Un [FinancialMovement] es cualquier evento que afecta el estado
/// financiero del usuario: un ingreso, un gasto o una transferencia
/// entre cuentas. Este modelo pertenece exclusivamente al dominio
/// y no conoce cómo se persiste ni se transmite — esa responsabilidad
/// vive en la capa de datos (ver FinancialMovementMapper).
class FinancialMovement {
  /// Identificador único del movimiento.
  final String id;

  /// Tipo de movimiento: ingreso, gasto o transferencia.
  final MovementType type;

  /// Monto del movimiento, siempre positivo.
  final double amount;

  /// Código ISO de la moneda (ej. 'COP', 'USD').
  final String currencyCode;

  /// Identificador de la categoría del movimiento.
  /// Para transferencias, se usa un valor convencional ('transferencia').
  final String categoryId;

  /// Identificador de la cuenta de origen.
  final String accountId;

  /// Identificador de la cuenta destino.
  /// Solo aplica cuando [type] es [MovementType.transferencia].
  final String? destinationAccountId;

  /// Fecha en la que ocurrió el movimiento (elegida por el usuario).
  final DateTime date;

  /// Nota o descripción opcional del movimiento.
  final String? notes;

  /// Estado de sincronización del movimiento.
  final MovementStatus status;

  /// Fecha y hora exacta en que se creó el registro en el sistema.
  /// Distinta de [date], que es la fecha declarada por el usuario.
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

  /// Retorna una copia de este movimiento con los campos
  /// especificados reemplazados. Campos no especificados
  /// conservan su valor original.
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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
