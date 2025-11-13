import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/carrito_provider.dart';

class CarritoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: Consumer<CarritoProvider>(
        builder: (context, carrito, _) {
          if (carrito.estaVacio) {
            return const Center(child: Text('El carrito está vacío'));
          }

          final items = carrito.items;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final producto = item.producto;
              return ListTile(
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    producto.imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image, color: Colors.white),
                      );
                    },
                  ),
                ),
                title: Text(producto.descripcion),
                subtitle: Text(
                    'Precio: ${producto.precio.toStringAsFixed(2)} • Cantidad: ${item.cantidad}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => carrito.eliminarProducto(producto.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}