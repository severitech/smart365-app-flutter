import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_tienda/data/carrito_provider.dart';

class CarritoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<CarritoProvider>(
        builder: (context, carrito, _) {
          if (carrito.estaVacio) {
            return const Center(
              child: Text(
                'El carrito está vacío.',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }

          final items = carrito.items;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final producto = item.producto;

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 3.0,
                      child: Row(
                        children: [
                          _ImagenProductoCarrito(imagenUrl: producto.imagen),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.nombre,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Bs. ${producto.precio.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text('Subtotal: Bs. ${item.subtotal.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      carrito.disminuirCantidad(producto.id),
                                ),
                                Text('${item.cantidad}',
                                    style: const TextStyle(fontSize: 16.0)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => carrito.agregarProducto(producto),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => carrito.eliminarProducto(producto.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _ResumenCarrito(carrito: carrito),
            ],
          );
        },
      ),
    );
  }
}

class _ImagenProductoCarrito extends StatelessWidget {
  const _ImagenProductoCarrito({required this.imagenUrl});

  final String imagenUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12.0)),
      child: imagenUrl.isEmpty
          ? _placeholder()
          : Image.network(
              imagenUrl,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 110,
      height: 110,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }
}

class _ResumenCarrito extends StatelessWidget {
  const _ResumenCarrito({required this.carrito});

  final CarritoProvider carrito;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Artículos: ${carrito.cantidadProductos}'),
              Text(
                'Total: Bs. ${carrito.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: carrito.estaVacio
                      ? null
                      : () => carrito.limpiarCarrito(),
                  child: const Text('Vaciar carrito'),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: carrito.estaVacio
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Pago realizado'),
                              content: const Text('Gracias por su compra.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    carrito.limpiarCarrito();
                                  },
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Pagar',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}