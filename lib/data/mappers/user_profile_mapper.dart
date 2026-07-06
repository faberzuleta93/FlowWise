import '../../domain/models/user_profile.dart';

/// Traduce entre [UserProfile] (dominio) y
/// Map<String, dynamic> (formato de persistencia).
class UserProfileMapper {
  const UserProfileMapper._();

  static Map<String, dynamic> toMap(UserProfile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'email': profile.email,
      'photoUrl': profile.photoUrl,
      'currency': profile.currency,
      'premium': profile.premium,
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      currency: map['currency'] as String,
      premium: map['premium'] as bool,
    );
  }
}
