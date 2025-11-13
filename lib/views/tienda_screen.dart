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
  String? rawResponse;
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
        rawResponse = null;
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
        title: const Text('Tienda'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (rawResponse != null && rawResponse!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.code),
              tooltip: 'Ver respuesta JSON',
              onPressed: _showRawResponse,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProductos,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12.0),
          const Text(
            'No se pudieron cargar los productos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12.0),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: () => _fetchProductos(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (productos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        children: const [
          Icon(Icons.store_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16.0),
          Center(
            child: Text(
              'No hay productos disponibles.',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return _ProductoCard(
          producto: producto,
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
        );
      },
    );
  }

  void _showRawResponse() {
    if (!mounted || rawResponse == null || rawResponse!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Respuesta JSON',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  if (requestUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        requestUrl!,
                        style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                    ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        rawResponse!,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductoCard extends StatelessWidget {
  const _ProductoCard({
    required this.producto,
    required this.onTap,
  });

  final Producto producto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ProductoImagen(imagenUrl: producto.imagen),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    'Bs. ${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Stock: ${producto.cantidad}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: producto.cantidad > 0 ? Colors.green : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductoImagen extends StatelessWidget {
  const _ProductoImagen({required this.imagenUrl});

  final String imagenUrl;

  @override
  Widget build(BuildContext context) {
    if (imagenUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imagenUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }
}