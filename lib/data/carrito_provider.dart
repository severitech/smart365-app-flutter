import 'package:flutter/material.dart';

import 'producto.dart';

class CarritoItem {
  CarritoItem({required this.producto, this.cantidad = 1});

  final Producto producto;
  int cantidad;

  double get subtotal => producto.precio * cantidad;
}

class CarritoProvider extends ChangeNotifier {
  final Map<int, CarritoItem> _items = {};

  List<CarritoItem> get items => _items.values.toList(growable: false);

  int get cantidadProductos =>
      _items.values.fold(0, (total, item) => total + item.cantidad);

  double get total =>
      _items.values.fold(0.0, (total, item) => total + item.subtotal);

  bool get estaVacio => _items.isEmpty;

  void agregarProducto(Producto producto) {
    final int key = producto.id;
    final itemExistente = _items[key];

    if (itemExistente != null) {
      itemExistente.cantidad += 1;
    } else {
      _items[key] = CarritoItem(producto: producto, cantidad: 1);
    }

    notifyListeners();
  }

  void disminuirCantidad(int productId) {
    final item = _items[productId];
    if (item == null) {
      return;
    }

    if (item.cantidad > 1) {
      item.cantidad -= 1;
    } else {
      _items.remove(productId);
    }

    notifyListeners();
  }

  void eliminarProducto(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }
}