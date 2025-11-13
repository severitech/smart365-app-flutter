import 'package:flutter/material.dart';
import '../data/carrito_provider.dart';

class CarritoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productos = CarritoProvider.productos;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
      ),
      body: productos.isEmpty
          ? Center(
              child: Text('El carrito está vacío'),
            )
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.network(
                      producto.imagenes[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: Icon(Icons.broken_image, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  title: Text(producto.descripcion),
                  subtitle: Text('Precio: ${producto.precio.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      CarritoProvider.eliminarProducto(producto);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarritoScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}