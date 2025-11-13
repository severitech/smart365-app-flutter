import 'package:flutter/material.dart';
import '../data/producto.dart';
import '../data/carrito_provider.dart';

class DetalleProductoScreen extends StatelessWidget {
  final Producto producto;
  final List<Producto> productosRelacionados;

  const DetalleProductoScreen({
    Key? key,
    required this.producto,
    required this.productosRelacionados,
  }) : super(key: key);

  void _agregarAlCarrito(BuildContext context, Producto producto) {
    CarritoProvider.agregarProducto(producto);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.descripcion} añadido al carrito'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Producto'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                producto.imagenes[0],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.descripcion,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Precio: ${producto.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Stock: ${producto.stock}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    producto.estado,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: producto.estado == 'Activo'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _agregarAlCarrito(context, producto),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  'Agregar al carrito',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Productos Relacionados',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            ...productosRelacionados.map((relacionado) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4.0,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        relacionado.imagenes[0],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(relacionado.descripcion),
                    subtitle: Text(
                      'Precio: ${relacionado.precio.toStringAsFixed(2)}',
                    ),
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
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
