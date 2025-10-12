import 'package:calet/shared/widgets/protected_screen_state.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/features/auth/service/google_auth.dart';
import 'package:calet/core/domain/entities/entities.dart';
import 'package:calet/features/profile/profile_header.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends ProtectedScreenStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProtectedScreenState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ProtectedScreenState<ProfileScreen> {
  @override
  Widget buildProtectedContent(BuildContext context, UserEntity user) {
    return VerticalViewStandardScrollable(
      title: 'Mi Perfil',
      appBarFloats: true,
      headerColor: Colors.indigo,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Editar perfil - Próximamente')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            // Mostrar confirmación antes de cerrar sesión
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cerrar Sesión'),
                content: const Text(
                  '¿Estás seguro de que quieres cerrar sesión?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              // Cerrar sesión

              await GoogleAuthService.instance.signOut(revoke: true);
              // El sessionProvider en `App.dart` se encargará de la redirección.
            }
          },
        ),
      ],
      child: Column(
        children: [
          // Avatar y información principal
          ProfileHeader(user: user),
          const SizedBox(height: 32),

          // Información del usuario
          _buildUserInfo(user),
          const SizedBox(height: 32),

          // Acciones del perfil
          _buildProfileActions(context),
        ],
      ),
    );
  }

  Widget _buildUserInfo(UserEntity user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email ?? 'No disponible',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.person,
              label: 'Nombre',
              value: user.displayName ?? 'No disponible',
            ),
            if (user.phoneNumber != null) ...[
              const Divider(),
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Teléfono',
                value: user.phoneNumber!,
              ),
            ],
            const Divider(),
            _buildInfoRow(
              icon: Icons.verified,
              label: 'Verificado',
              value: user.isEmailVerified ? 'Sí' : 'No',
              valueColor: user.isEmailVerified ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Acciones del Perfil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              icon: Icons.edit,
              label: 'Editar Perfil',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Editar perfil - Próximamente')),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.security,
              label: 'Seguridad',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seguridad - Próximamente')),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.notifications,
              label: 'Notificaciones',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notificaciones - Próximamente'),
                  ),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.help,
              label: 'Ayuda',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ayuda - Próximamente')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 120,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          backgroundColor: Colors.indigo.shade50,
          foregroundColor: Colors.indigo.shade700,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
