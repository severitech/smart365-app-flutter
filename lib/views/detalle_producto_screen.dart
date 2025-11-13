import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/producto.dart';
import '../data/carrito_provider.dart';

class DetalleProductoScreen extends StatefulWidget {
  const DetalleProductoScreen({
    super.key,
    required this.producto,
    required this.productosRelacionados,
  });

  final Producto producto;
  final List<Producto> productosRelacionados;

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  late List<Producto> _relacionados;
  bool _cargandoRelacionados = false;
  String? _errorRelacionados;

  @override
  void initState() {
    super.initState();
    _relacionados = widget.productosRelacionados
        .where((producto) => _esRelacionado(producto))
        .toList();
    _fetchProductosRelacionados();
  }

  bool _esRelacionado(Producto producto) {
    return producto.id != widget.producto.id &&
        producto.subcategoriaId != null &&
        widget.producto.subcategoriaId != null &&
        producto.subcategoriaId == widget.producto.subcategoriaId;
  }

  Future<void> _fetchProductosRelacionados() async {
    if (widget.producto.subcategoriaId == null) {
      return;
    }

    setState(() {
      _cargandoRelacionados = true;
      _errorRelacionados = null;
    });

    try {
      final productos = await Producto.fetchProductos(
        queryParameters: {
          'subcategoria': widget.producto.subcategoriaId!.toString(),
          'estado': 'Activo',
        },
      );

      setState(() {
        _relacionados = productos
            .where((producto) => producto.id != widget.producto.id)
            .toList();
      });
    } catch (e) {
      setState(() {
        _errorRelacionados = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargandoRelacionados = false;
        });
      }
    }
  }

  void _agregarAlCarrito(BuildContext context, Producto producto) {
    context.read<CarritoProvider>().agregarProducto(producto);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.descripcion} añadido al carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Producto'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductoImagenDetalle(imagenUrl: producto.imagen),
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
                  const SizedBox(height: 8.0),
                  Text(
                    'Precio: ${producto.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Stock: ${producto.stock}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    producto.estado,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: producto.estado == 'Activo'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  if (producto.subcategoriaNombre != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Subcategoría: ${producto.subcategoriaNombre}',
                        style: const TextStyle(fontSize: 16.0),
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
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
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
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Productos Relacionados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualizar relacionados',
          onPressed:
            _cargandoRelacionados ? null : () => _fetchProductosRelacionados(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            if (_cargandoRelacionados)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorRelacionados != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _errorRelacionados!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
            else if (_relacionados.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('No hay productos relacionados para mostrar.'),
              )
            else
              Column(
                children: _relacionados.map((relacionado) {
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
                          child: _MiniaturaProducto(imagenUrl: relacionado.imagen),
                        ),
                        title: Text(relacionado.descripcion),
                        subtitle: Text(
                          'Precio: ${relacionado.precio.toStringAsFixed(2)}',
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleProductoScreen(
                                producto: relacionado,
                                productosRelacionados: _relacionados,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}

class _ProductoImagenDetalle extends StatelessWidget {
  const _ProductoImagenDetalle({required this.imagenUrl});

  final String imagenUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10.0)),
      child: imagenUrl.isEmpty
          ? _buildPlaceholder()
          : Image.network(
              imagenUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: Colors.grey,
      ),
    );
  }
}

class _MiniaturaProducto extends StatelessWidget {
  const _MiniaturaProducto({required this.imagenUrl});

  final String imagenUrl;

  @override
  Widget build(BuildContext context) {
    if (imagenUrl.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      imagenUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 24,
        color: Colors.grey,
      ),
    );
  }
}
