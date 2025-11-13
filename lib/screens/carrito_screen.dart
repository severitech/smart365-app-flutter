import 'package:flutter/material.dart';
import 'package:app_tienda/data/carrito_provider.dart';

class CarritoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final carrito = CarritoProvider.productos;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.white,
        child: carrito.isEmpty
            ? Center(
                child: Text(
                  'El carrito está vacío.',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.length,
                      itemBuilder: (context, index) {
                        final producto = carrito[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(producto.imagen),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producto.nombre,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text('Cantidad: ${producto.cantidad}'),
                                      Text('Precio: ${producto.precio}'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Pago realizado'),
                            content: Text('Gracias por su compra.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        'Pagar',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}