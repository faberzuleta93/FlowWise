import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../presentation/auth/auth_form_viewmodel.dart';

/// Pantalla de login/registro con email.
///
/// Regla 5: nunca navega como consecuencia del cambio de
/// autenticación. Tras un login exitoso, AppRoot detecta la
/// sesión y representa el nuevo estado.
class AuthScreen extends StatefulWidget {
  final AuthenticationRepository authRepository;

  const AuthScreen({super.key, required this.authRepository});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final AuthFormViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = AuthFormViewModel(repository: widget.authRepository);
  }

  @override
  void dispose() {
    _vm.dispose(); // Regla 4: esta pantalla es propietaria del VM.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    _vm.isRegister ? 'Crea tu cuenta' : 'Hola de nuevo',
                    style: AppTypography.heading1(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _vm.isRegister
                        ? 'Empieza a darle propósito a tu dinero'
                        : 'Inicia sesión para continuar',
                    style: AppTypography.caption(),
                  ),
                  const SizedBox(height: 28),
                  if (_vm.isRegister) ...[
                    _Campo(
                      label: 'Nombre',
                      hint: '¿Cómo te llamas?',
                      onChanged: _vm.updateName,
                    ),
                    const SizedBox(height: 14),
                  ],
                  _Campo(
                    label: 'Correo',
                    hint: 'tu@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _vm.updateEmail,
                  ),
                  const SizedBox(height: 14),
                  _Campo(
                    label: 'Contraseña',
                    hint: 'Mínimo 8 caracteres',
                    obscure: true,
                    onChanged: _vm.updatePassword,
                  ),
                  if (_vm.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _ErrorBanner(message: _vm.errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  _BotonPrincipal(
                    label: _vm.isRegister ? 'Crear cuenta' : 'Iniciar sesión',
                    loading: _vm.isLoading,
                    onTap: _vm.isLoading ? null : _vm.submit,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: _vm.isLoading ? null : _vm.toggleMode,
                      child: Text.rich(
                        TextSpan(
                          text: _vm.isRegister
                              ? '¿Ya tienes cuenta? '
                              : '¿Aún no tienes cuenta? ',
                          style: AppTypography.caption(),
                          children: [
                            TextSpan(
                              text: _vm.isRegister
                                  ? 'Inicia sesión'
                                  : 'Regístrate',
                              style: AppTypography.caption(
                                  color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // TODO(Sprint-3+): '¿Olvidaste tu contraseña?' —
                  // deuda documentada, decisión de producto V2.
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _Campo({
    required this.label,
    required this.hint,
    required this.onChanged,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption()),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: AppTypography.bodyMedium(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child:
          Text(message, style: AppTypography.caption(color: AppColors.danger)),
    );
  }
}

class _BotonPrincipal extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _BotonPrincipal({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: loading ? 0.6 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.midnight),
                )
              : Text(label,
                  style: AppTypography.bodyMedium(color: AppColors.midnight)),
        ),
      ),
    );
  }
}
