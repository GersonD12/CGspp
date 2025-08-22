/// Entidad de Usuario del dominio de la aplicación
/// 
/// Esta entidad es independiente de la fuente de datos (Firebase, API, etc.)
/// Define la estructura y comportamiento del usuario en el negocio
class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.isEmailVerified = false,
  });

  /// Crea una copia de la entidad con cambios
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? isEmailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  /// Obtiene el nombre para mostrar (displayName o email como fallback)
  String get displayNameOrEmail {
    return displayName ?? email ?? 'Usuario';
  }

  /// Obtiene las iniciales del usuario para avatares
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }

  /// Convierte la entidad a un Map (útil para serialización)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Crea una entidad desde un Map (útil para deserialización)
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }

  /// Crea una entidad desde Firebase User
  factory UserEntity.fromFirebaseUser(dynamic firebaseUser) {
    return UserEntity(
      id: firebaseUser.uid ?? '',
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      isEmailVerified: firebaseUser.emailVerified ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName)';
  }
}

