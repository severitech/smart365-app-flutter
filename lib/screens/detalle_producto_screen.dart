import 'package:flutter/material.dart';
import '../models/producto.dart';

class DetalleProductoScreen extends StatelessWidget {
  final Producto producto;
  final List<Producto> productosRelacionados;

  DetalleProductoScreen({required this.producto, required this.productosRelacionados});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Producto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              producto.imagenes[0],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                producto.descripcion,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
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
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Productos Relacionados',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            ...productosRelacionados.map((relacionado) {
              return ListTile(
                leading: Image.network(
                  relacionado.imagenes[0],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(relacionado.descripcion),
                subtitle: Text('Precio: ${relacionado.precio.toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleProductoScreen(
                        producto: relacionado,
                        productosRelacionados: productosRelacionados,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}