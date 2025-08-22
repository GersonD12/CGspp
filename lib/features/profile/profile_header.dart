import 'package:flutter/material.dart';
import 'package:calet/core/domain/entities/entities.dart';

/// Widget que muestra el header del perfil con avatar, nombre, email y badge de verificación
class ProfileHeader extends StatelessWidget {
  final UserEntity user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.indigo.shade100,
          backgroundImage: user.photoURL != null 
            ? NetworkImage(user.photoURL!) 
            : null,
          child: user.photoURL == null
            ? Text(
                user.initials,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade600,
                ),
              )
            : null,
        ),
        const SizedBox(height: 16),
        
        // Nombre
        Text(
          user.displayNameOrEmail,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Email
        Text(
          user.email ?? '',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        
        // Badge de verificación
        if (user.isEmailVerified) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Verificado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
