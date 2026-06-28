enum AccountType { cash, bank, creditCard, digital }

class Account {
  final String id;
  final String name;
  final String emoji;
  final AccountType type;
  final String currencyCode;
  final double balance;
  final bool isDefault;
  // Preparado para: límite de crédito, color, institución
  final int sortOrder;

  const Account({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    this.currencyCode = 'COP',
    this.balance = 0,
    this.isDefault = false,
    this.sortOrder = 0,
  });
}

class DefaultAccounts {
  static const List<Account> all = [
    Account(
      id: 'efectivo',
      name: 'Efectivo',
      emoji: '💵',
      type: AccountType.cash,
      isDefault: true,
      sortOrder: 1,
    ),
    Account(
      id: 'banco',
      name: 'Banco',
      emoji: '🏦',
      type: AccountType.bank,
      sortOrder: 2,
    ),
    Account(
      id: 'tarjeta',
      name: 'Tarjeta',
      emoji: '💳',
      type: AccountType.creditCard,
      sortOrder: 3,
    ),
  ];
}
