import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/auth_provider.dart';
import '../data/pedidos_service.dart';
import '../models/venta.dart';

class MisPedidosScreen extends StatefulWidget {
  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  Future<List<Venta>>? _futurePedidos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();
    if (_futurePedidos == null && authProvider.isAuthenticated) {
      final token = authProvider.token;
      final user = authProvider.user;
      if (token != null && user != null) {
        _futurePedidos = PedidosService.instance.obtenerMisPedidos(
          token: token,
          userId: user.id,
        );
      }
    }
  }

  Future<void> _recargarPedidos() async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;
    final user = authProvider.user;
    if (token == null || user == null) {
      return;
    }
    final future = PedidosService.instance.obtenerMisPedidos(
      token: token,
      userId: user.id,
    );
    setState(() {
      _futurePedidos = future;
    });
    try {
      await future;
    } catch (_) {
      // El FutureBuilder mostrará el error correspondiente
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mis pedidos'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                'Debes iniciar sesión para ver tus pedidos',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _recargarPedidos,
        child: FutureBuilder<List<Venta>>(
          future: _futurePedidos,
          builder: (context, snapshot) {
            if (_futurePedidos == null ||
                snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _recargarPedidos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final pedidos = snapshot.data ?? [];

            if (pedidos.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Aún no tienes pedidos registrados',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: pedidos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pedido #${pedido.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Chip(
                              label: Text(pedido.estado),
                              backgroundColor: Colors.deepPurple.withOpacity(0.1),
                              labelStyle: const TextStyle(color: Colors.deepPurple),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pedido.fecha != null
                              ? 'Fecha: ${_formatDate(pedido.fecha!)}'
                              : 'Fecha no disponible',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: Bs ${pedido.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (pedido.detalles.isNotEmpty) ...[
                          const Divider(height: 24),
                          const Text(
                            'Detalle',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...pedido.detalles.map(
                            (detalle) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 18, color: Colors.deepPurple),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${detalle.cantidad} x ${detalle.productoNombre ?? 'Producto'}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Bs ${detalle.subtotal.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
