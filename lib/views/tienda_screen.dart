import 'dart:convert';

import 'package:flutter/material.dart';
import '../data/producto.dart';
import 'detalle_producto_screen.dart';

class TiendaScreen extends StatefulWidget {
  @override
  _TiendaScreenState createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  List<Producto> productos = [];
  bool isLoading = false;
  String rawResponse = '';
  String? requestUrl;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await Producto.fetchProductosWithRaw(
        overrideBaseUrl: 'https://web-production-de7b5.up.railway.app/api',
      );
      setState(() {
        productos = result.productos;
        rawResponse = _formatJson(result.rawBody);
        requestUrl = result.requestUri.toString();
      });
    } catch (e) {
      setState(() {
        productos = [];
        rawResponse = '';
        requestUrl = null;
        errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los productos: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatJson(String source) {
    try {
      final dynamic decoded = json.decode(source);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return source;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProductos,
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 320,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (requestUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'URL solicitada: $requestUrl',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (rawResponse.isNotEmpty)
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SelectableText(
                          rawResponse,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0),
                        ),
                      ),
                    ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  if (productos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: Center(
                        child: Text('No hay productos disponibles.'),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
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
                                  productosRelacionados: productos,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 4.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10.0),
                                    ),
                                    child: Image.network(
                                      producto.imagen,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producto.descripcion,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text('Precio: ${producto.precio.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }
}