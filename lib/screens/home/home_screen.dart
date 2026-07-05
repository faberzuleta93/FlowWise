import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../domain/models/home_view_model.dart';
import '../../state/financial_state_notifier.dart';
import '../../domain/models/financial_movement.dart';
import 'widgets/home_header.dart';
import 'widgets/financial_status_card.dart';
import 'widgets/daily_spending_card.dart';
import 'widgets/budget_blocks_card.dart';
import 'widgets/recent_movements_card.dart';
import '../../presentation/home/mappers/decision_ui_mapper.dart';
import 'widgets/decisions_card.dart';

class HomeScreen extends StatefulWidget {
  final FinancialStateNotifier financialNotifier;

  const HomeScreen({
    super.key,
    required this.financialNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Nota: la inicialización del FinancialStateNotifier ocurre
  // únicamente en main.dart, antes de runApp(). Este widget
  // solo escucha y renderiza el estado.

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.financialNotifier,
      builder: (context, _) {
        final notifier = widget.financialNotifier;

        // Estado de carga
        if (notifier.isLoading) {
          return const _LoadingState();
        }

        // Estado de error
        if (notifier.error != null) {
          return _ErrorState(
            message: notifier.error!,
            onRetry: () => widget.financialNotifier.initialize(),
          );
        }

        final state = notifier.state;

        // Construir bloques desde el FinancialState
        final bloques = [
          BloquePresupuesto(
            nombre: 'Esenciales',
            emoji: '🏠',
            max: state.budget.essentials.allocated,
            gasto: state.budget.essentials.spent,
            color: AppColors.bloqueEsenciales,
          ),
          BloquePresupuesto(
            nombre: 'Estilo de vida',
            emoji: '🎭',
            max: state.budget.lifestyle.allocated,
            gasto: state.budget.lifestyle.spent,
            color: AppColors.bloqueEstilo,
          ),
          BloquePresupuesto(
            nombre: 'Futuro',
            emoji: '🌱',
            max: state.budget.future.allocated,
            gasto: state.budget.future.spent,
            color: AppColors.bloqueFuturo,
          ),
        ];

        // TODO(Sprint-3): extraer _toMovimientoReciente y los mapas de
        // categorías/cuentas a un MovementPresentationMapper cuando exista
        // la pantalla de Movimientos (segundo consumidor real — YAGNI).
        final movimientos =
            state.recentMovements.map((m) => _toMovimientoReciente(m)).toList();
        final decisionesUi = DecisionUiMapper.mapAll(state.decisions);
        return Scaffold(
          backgroundColor: AppColors.midnight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // TODO(Sprint-3 Auth): reemplazar nombreUsuario, inicial y
                  // esPremium por la información real del usuario autenticado.
                  const HomeHeader(
                    nombreUsuario: 'Faber',
                    esPremium: false,
                    inicial: 'F',
                  ),
                  const SizedBox(height: 20),
                  FinancialStatusCard(
                    ingresosMes: state.monthSummary.totalIncome,
                    gastosMes: state.monthSummary.totalExpenses,
                    balance: state.monthSummary.balance,
                  ),
                  DecisionsCard(
                    decisions: decisionesUi,
                    // TODO(Sprint-3): resolver navegación según DecisionAction.
                    onActionTap: (_) {},
                  ),
                  DailySpendingCard(
                    disponibleHoy: state.liquidity.availableToday,
                    sinAsignar: state.liquidity.unassignedMoney,
                  ),
                  BudgetBlocksCard(bloques: bloques),
                  if (movimientos.isNotEmpty)
                    RecentMovementsCard(movimientos: movimientos),
                  if (movimientos.isEmpty) const _EmptyMovements(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  MovimientoReciente _toMovimientoReciente(FinancialMovement m) {
    final esIngreso = m.type == MovementType.ingreso;
    final esTransferencia = m.type == MovementType.transferencia;

    String emoji;
    if (esTransferencia) {
      emoji = '↔️';
    } else if (esIngreso) {
      emoji = '💼';
    } else {
      emoji = _emojiForCategory(m.categoryId);
    }

    return MovimientoReciente(
      emoji: emoji,
      nombre: _labelForCategory(m.categoryId),
      subtitulo: '${_labelForAccount(m.accountId)} · ${_labelForType(m.type)}',
      monto: esIngreso ? m.amount : -m.amount,
      esTransferencia: esTransferencia,
    );
  }

  String _emojiForCategory(String categoryId) {
    const map = {
      'vivienda': '🏠',
      'mercado': '🛒',
      'transporte': '🚗',
      'salud': '💊',
      'restaurantes': '🍔',
      'entretenimiento': '🎭',
      'ropa': '👗',
      'suscripciones': '📱',
      'ahorro': '🏦',
      'inversion': '📈',
      'educacion': '📚',
      'otros_gastos': '📦',
      'salario': '💼',
      'freelance': '🔧',
    };
    return map[categoryId] ?? '💰';
  }

  String _labelForCategory(String categoryId) {
    const map = {
      'vivienda': 'Vivienda',
      'mercado': 'Mercado',
      'transporte': 'Transporte',
      'salud': 'Salud',
      'restaurantes': 'Restaurantes',
      'entretenimiento': 'Entretenimiento',
      'ropa': 'Ropa',
      'suscripciones': 'Suscripciones',
      'ahorro': 'Ahorro',
      'inversion': 'Inversión',
      'educacion': 'Educación',
      'otros_gastos': 'Otros',
      'salario': 'Salario',
      'freelance': 'Freelance',
      'transferencia': 'Transferencia',
    };
    return map[categoryId] ?? categoryId;
  }

  String _labelForAccount(String accountId) {
    const map = {
      'efectivo': 'Efectivo',
      'banco': 'Banco',
      'tarjeta': 'Tarjeta',
    };
    return map[accountId] ?? accountId;
  }

  String _labelForType(MovementType type) {
    return switch (type) {
      MovementType.ingreso => 'Ingreso',
      MovementType.gasto => 'Gasto',
      MovementType.transferencia => 'Transferencia',
    };
  }
}

// ── ESTADOS AUXILIARES ────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.midnight,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Text('💸', style: TextStyle(fontSize: 36)),
          SizedBox(height: 12),
          Text(
            'Aún no tienes movimientos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Registra tu primer ingreso\ntocando el botón +',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
