import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:app_tienda/data/auth_provider.dart';
import 'package:app_tienda/data/carrito_provider.dart';
import 'package:app_tienda/data/pagos_service.dart';

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

class _ResumenCarrito extends StatefulWidget {
  const _ResumenCarrito({required this.carrito});

  final CarritoProvider carrito;

  @override
  State<_ResumenCarrito> createState() => _ResumenCarritoState();
}

class _ResumenCarritoState extends State<_ResumenCarrito> {
  bool _isProcessingCheckout = false;

  @override
  Widget build(BuildContext context) {
    final carrito = widget.carrito;

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
                  onPressed: carrito.estaVacio || _isProcessingCheckout
                      ? null
                      : carrito.limpiarCarrito,
                  child: const Text('Vaciar carrito'),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: carrito.estaVacio || _isProcessingCheckout
                      ? null
                      : _iniciarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isProcessingCheckout
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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

  Future<void> _iniciarPago() async {
    final carrito = widget.carrito;
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para completar tu compra.')),
      );
      return;
    }

    final token = authProvider.token;
    final user = authProvider.user;

    if (token == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible validar tu sesión. Intenta nuevamente.')),
      );
      return;
    }

    final items = carrito.items
        .map(
          (item) => CheckoutItem(
            productoId: item.producto.id,
            nombre: item.producto.nombre,
            precio: item.producto.precio,
            cantidad: item.cantidad,
          ),
        )
        .toList(growable: false);

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu carrito está vacío.')),
      );
      return;
    }

    setState(() {
      _isProcessingCheckout = true;
    });

    try {
      final session = await PagosService.instance.crearCheckoutSession(
        token: token,
        items: items,
        descripcion: 'Compra desde la app móvil',
        usuarioId: user.id,
      );

      if (session.checkoutUrl.isEmpty) {
        throw PagosException('No se recibió la URL de pago de Stripe.');
      }

      final result = await Navigator.of(context).push<CheckoutResult>(
        MaterialPageRoute(
          builder: (_) => _CheckoutWebView(
            initialUrl: session.checkoutUrl,
            successIndicators: const ['pago-exitoso', 'pago-exitoso-mobile'],
            cancelIndicators: const ['pago-cancelado', 'pago-cancelado-mobile'],
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (result == CheckoutResult.success) {
        await _verificarPago(token, session.sessionId);
      } else if (result == CheckoutResult.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El pago fue cancelado.')),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapError(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
        });
      }
    }
  }

  Future<void> _verificarPago(String token, String sessionId) async {
    final carrito = widget.carrito;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _isProcessingCheckout = true;
    });

    try {
      final resultado = await PagosService.instance.verificarPago(
        token: token,
        sessionId: sessionId,
      );

      if (!mounted) {
        return;
      }

      if (resultado.pagoExitoso) {
        carrito.limpiarCarrito();
        navigator.popUntil((route) => route.isFirst);
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Venta correctamente guardada.'),
            action: SnackBarAction(
              label: 'Ver pedidos',
              onPressed: () => navigator.pushNamed('/mis-pedidos'),
            ),
          ),
        );
      } else {
        final mensaje = resultado.mensaje ??
            'El pago todavía no se registra. Intenta nuevamente en unos segundos.';
        messenger.showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(_mapError(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
        });
      }
    }
  }

  String _mapError(Object error) {
    if (error is PagosException) {
      return error.message;
    }
    final message = error.toString();
    const prefix = 'Exception: ';
    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }
    return message;
  }
}

enum CheckoutResult { success, cancelled }

class _CheckoutWebView extends StatefulWidget {
  const _CheckoutWebView({
    required this.initialUrl,
    required this.successIndicators,
    required this.cancelIndicators,
  });

  final String initialUrl;
  final List<String> successIndicators;
  final List<String> cancelIndicators;

  @override
  State<_CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<_CheckoutWebView> {
  late final WebViewController _controller;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageFinished: (_) {
            setState(() {
              _progress = 1;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (_matchesAny(url, widget.successIndicators)) {
              Navigator.of(context).pop(CheckoutResult.success);
              return NavigationDecision.prevent;
            }
            if (_matchesAny(url, widget.cancelIndicators)) {
              Navigator.of(context).pop(CheckoutResult.cancelled);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(CheckoutResult.cancelled);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pago con Stripe'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_progress < 1)
              Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(
                  value: _progress < 0.05 ? null : _progress,
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _matchesAny(String url, List<String> indicators) {
    final lowerUrl = url.toLowerCase();
    for (final indicator in indicators) {
      if (indicator.isNotEmpty && lowerUrl.contains(indicator.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}