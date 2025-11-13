import 'package:flutter/material.dart';
import '../models/producto.dart';
import 'detalle_producto_screen.dart';

class TiendaScreen extends StatelessWidget {
  final List<Producto> productos = [
    Producto(
      descripcion: 'Producto 1',
      precio: 100.0,
      stock: 10,
      imagenes: ['https://via.placeholder.com/150'],
      estado: 'Activo',
    ),
    Producto(
      descripcion: 'Producto 2',
      precio: 200.0,
      stock: 5,
      imagenes: ['https://via.placeholder.com/150'],
      estado: 'Activo',
    ),
    Producto(
      descripcion: 'Producto 3',
      precio: 300.0,
      stock: 0,
      imagenes: ['https://via.placeholder.com/150'],
      estado: 'Inactivo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navegar al carrito
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navegar al perfil
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.75,
        ),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleProductoScreen(
                    producto: producto,
                    productosRelacionados: productos.where((p) => p != producto).toList(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    producto.imagenes[0],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      producto.descripcion,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Precio: ${producto.precio.toStringAsFixed(2)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Stock: ${producto.stock}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      producto.estado,
                      style: TextStyle(
                        color: producto.estado == 'Activo' ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}