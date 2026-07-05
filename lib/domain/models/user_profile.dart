/// Identidad del usuario dentro de FlowWise.
///
/// Representa QUIÉN es la persona, no su situación financiera
/// (ver FinancialProfile) ni su sesión (ver AuthenticationRepository).
class UserProfile {
  final String id;
  final String name;
  final String email;

  /// Foto del proveedor de auth (Google/Apple). Null → se usa la inicial.
  final String? photoUrl;

  /// Código ISO de la moneda preferida (ej. 'COP').
  final String currency;

  final bool premium;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.currency = 'COP',
    this.premium = false,
  });

  /// Inicial para el avatar cuando no hay foto.
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? currency,
    bool? premium,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      currency: currency ?? this.currency,
      premium: premium ?? this.premium,
    );
  }
}
