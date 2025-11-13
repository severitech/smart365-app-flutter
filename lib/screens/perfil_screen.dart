import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/auth_provider.dart';

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: authProvider.isAuthenticated && user != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.deepPurple.withOpacity(0.2),
                                child: Text(
                                  _obtenerIniciales(user.firstName, user.lastName),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user.firstName} ${user.lastName}'.trim().isEmpty
                                          ? 'Sin nombre registrado'
                                          : '${user.firstName} ${user.lastName}'.trim(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: 'Teléfono',
                            value: user.profile?.telefono ?? 'No registrado',
                            icon: Icons.phone,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Rol',
                            value: user.profile?.rol ?? 'No asignado',
                            icon: Icons.verified_user,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'ID de usuario',
                            value: user.id.toString(),
                            icon: Icons.badge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/mis-pedidos');
                    },
                    icon: const Icon(Icons.receipt_long),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: const Text(
                      'Mis pedidos',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _cerrarSesion(context),
                    icon: const Icon(Icons.logout, color: Colors.deepPurple),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_outline, size: 72, color: Colors.deepPurple),
                    const SizedBox(height: 24),
                    const Text(
                      'Inicia sesión para acceder a tu perfil',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _obtenerIniciales(String firstName, String lastName) {
    final buffer = StringBuffer();
    if (firstName.isNotEmpty) {
      buffer.write(firstName[0].toUpperCase());
    }
    if (lastName.isNotEmpty) {
      buffer.write(lastName[0].toUpperCase());
    }
    final result = buffer.toString();
    return result.isEmpty ? '?' : result;
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<AuthProvider>().logout();
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Sesión cerrada correctamente')),
    );
    if (!navigator.mounted) {
      return;
    }
    navigator.pop();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}