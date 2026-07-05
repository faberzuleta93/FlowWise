import 'data/repositories/firebase_authentication_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'core/theme/typography.dart';
import 'data/datasources/shared_preferences_movement_datasource.dart';
import 'data/repositories/local_movement_repository.dart';
import 'domain/financialCore/engine/financial_engine_v1.dart';
import 'state/financial_state_notifier.dart';
import 'state/auth_state_notifier.dart';
import 'screens/home/home_screen.dart';
import 'screens/movimientos/movimientos_screen.dart';
import 'screens/informes/informes_screen.dart';
import 'screens/perfil/perfil_screen.dart';
import 'screens/registro/registro_screen.dart';
import 'navigation/app_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// Cadena de dependencias:
  // Datasource → Repository → Engine → Notifier
  final datasource = SharedPreferencesMovementDatasource();
  final repository = LocalMovementRepository(datasource: datasource);
  final engine = FinancialEngineV1(movementRepository: repository);
  final financialNotifier = FinancialStateNotifier(engine: engine);

  // Autenticación
  final authRepository = FirebaseAuthenticationRepository();
  final authNotifier = AuthStateNotifier(repository: authRepository);

  await financialNotifier.initialize();

  runApp(FlowWiseApp(
    financialNotifier: financialNotifier,
    authNotifier: authNotifier,
  ));
}

class FlowWiseApp extends StatelessWidget {
  final FinancialStateNotifier financialNotifier;
  final AuthStateNotifier authNotifier;

  const FlowWiseApp({
    super.key,
    required this.financialNotifier,
    required this.authNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: AppRoot(
        financialNotifier: financialNotifier,
        authNotifier: authNotifier,
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  final FinancialStateNotifier financialNotifier;

  const MainNavigator({
    super.key,
    required this.financialNotifier,
  });

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(financialNotifier: widget.financialNotifier),
      const MovimientosScreen(),
      const InformesScreen(),
      const PerfilScreen(),
    ];
  }

  void _abrirRegistro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RegistroScreen(
        financialNotifier: widget.financialNotifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _abrirRegistro,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.midnight,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Inicio'),
            _buildNavItem(1, Icons.receipt_long_rounded, 'Movimientos'),
            const SizedBox(width: 58),
            _buildNavItem(2, Icons.bar_chart_rounded, 'Informes'),
            _buildNavItem(3, Icons.person_rounded, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final activo = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: activo ? AppColors.accent : AppColors.textSecondary,
                size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.micro(
                    color:
                        activo ? AppColors.accent : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
