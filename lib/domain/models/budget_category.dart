enum CategoryType { ingreso, gasto }

enum BudgetBlock { esenciales, estiloDeVida, futuro }

class BudgetCategory {
  final String id;
  final String name;
  final String emoji;
  final CategoryType type;
  final BudgetBlock block;
  final bool isDefault;
  // Preparado para Premium: color, orden, subcategorías
  final int sortOrder;

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.block,
    this.isDefault = true,
    this.sortOrder = 0,
  });
}

// Catálogo de categorías base — Free tier
class DefaultCategories {
  static const List<BudgetCategory> gastos = [
    BudgetCategory(
      id: 'vivienda',
      name: 'Vivienda',
      emoji: '🏠',
      type: CategoryType.gasto,
      block: BudgetBlock.esenciales,
      sortOrder: 1,
    ),
    BudgetCategory(
      id: 'mercado',
      name: 'Mercado',
      emoji: '🛒',
      type: CategoryType.gasto,
      block: BudgetBlock.esenciales,
      sortOrder: 2,
    ),
    BudgetCategory(
      id: 'transporte',
      name: 'Transporte',
      emoji: '🚗',
      type: CategoryType.gasto,
      block: BudgetBlock.esenciales,
      sortOrder: 3,
    ),
    BudgetCategory(
      id: 'salud',
      name: 'Salud',
      emoji: '💊',
      type: CategoryType.gasto,
      block: BudgetBlock.esenciales,
      sortOrder: 4,
    ),
    BudgetCategory(
      id: 'restaurantes',
      name: 'Restaurantes',
      emoji: '🍔',
      type: CategoryType.gasto,
      block: BudgetBlock.estiloDeVida,
      sortOrder: 5,
    ),
    BudgetCategory(
      id: 'entretenimiento',
      name: 'Entretenimiento',
      emoji: '🎭',
      type: CategoryType.gasto,
      block: BudgetBlock.estiloDeVida,
      sortOrder: 6,
    ),
    BudgetCategory(
      id: 'ropa',
      name: 'Ropa',
      emoji: '👗',
      type: CategoryType.gasto,
      block: BudgetBlock.estiloDeVida,
      sortOrder: 7,
    ),
    BudgetCategory(
      id: 'suscripciones',
      name: 'Suscripciones',
      emoji: '📱',
      type: CategoryType.gasto,
      block: BudgetBlock.estiloDeVida,
      sortOrder: 8,
    ),
    BudgetCategory(
      id: 'ahorro',
      name: 'Ahorro',
      emoji: '🏦',
      type: CategoryType.gasto,
      block: BudgetBlock.futuro,
      sortOrder: 9,
    ),
    BudgetCategory(
      id: 'inversion',
      name: 'Inversión',
      emoji: '📈',
      type: CategoryType.gasto,
      block: BudgetBlock.futuro,
      sortOrder: 10,
    ),
    BudgetCategory(
      id: 'educacion',
      name: 'Educación',
      emoji: '📚',
      type: CategoryType.gasto,
      block: BudgetBlock.futuro,
      sortOrder: 11,
    ),
    BudgetCategory(
      id: 'otros_gastos',
      name: 'Otros',
      emoji: '📦',
      type: CategoryType.gasto,
      block: BudgetBlock.esenciales,
      sortOrder: 12,
    ),
  ];

  static const List<BudgetCategory> ingresos = [
    BudgetCategory(
      id: 'salario',
      name: 'Salario',
      emoji: '💼',
      type: CategoryType.ingreso,
      block: BudgetBlock.esenciales,
      sortOrder: 1,
    ),
    BudgetCategory(
      id: 'freelance',
      name: 'Freelance',
      emoji: '🔧',
      type: CategoryType.ingreso,
      block: BudgetBlock.esenciales,
      sortOrder: 2,
    ),
  ];
}
