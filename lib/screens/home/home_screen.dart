import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/home_view_model.dart';
import 'widgets/home_header.dart';
import 'widgets/financial_status_card.dart';
import 'widgets/daily_spending_card.dart';
import 'widgets/budget_blocks_card.dart';
import 'widgets/recent_movements_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final HomeViewModel _vm = HomeViewModel(
    ingresosMes: 3000000,
    gastosMes: 2680000,
    disponibleHoy: 14545,
    sinAsignar: 320000,
    diasRestantes: 22,
    bloques: [
      BloquePresupuesto(
        nombre: 'Esenciales',
        emoji: '🏠',
        max: 1500000,
        gasto: 1320000,
        color: AppColors.bloqueEsenciales,
      ),
      BloquePresupuesto(
        nombre: 'Estilo de vida',
        emoji: '🎭',
        max: 900000,
        gasto: 940000,
        color: AppColors.bloqueEstilo,
      ),
      BloquePresupuesto(
        nombre: 'Futuro',
        emoji: '🌱',
        max: 600000,
        gasto: 420000,
        color: AppColors.bloqueFuturo,
      ),
    ],
    movimientos: [
      MovimientoReciente(
        emoji: '🏠',
        nombre: 'Arriendo',
        subtitulo: 'Banco · Esenciales',
        monto: -800000,
      ),
      MovimientoReciente(
        emoji: '↔️',
        nombre: 'Retiro cajero',
        subtitulo: 'Banco → Efectivo',
        monto: 200000,
        esTransferencia: true,
      ),
      MovimientoReciente(
        emoji: '💼',
        nombre: 'Salario',
        subtitulo: 'Banco · Ingreso',
        monto: 3000000,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                nombreUsuario: 'Faber',
                esPremium: false,
                inicial: 'F',
              ),
              const SizedBox(height: 20),
              FinancialStatusCard(
                ingresosMes: _vm.ingresosMes,
                gastosMes: _vm.gastosMes,
                balance: _vm.balance,
              ),
              DailySpendingCard(
                disponibleHoy: _vm.disponibleHoy,
                sinAsignar: _vm.sinAsignar,
              ),
              BudgetBlocksCard(bloques: _vm.bloques),
              RecentMovementsCard(movimientos: _vm.movimientos),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
