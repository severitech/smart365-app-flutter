import 'package:flutter/material.dart';
import 'producto.dart';

class CarritoProvider {
  static final List<Producto> _productosEnCarrito = [];

  static List<Producto> get productos => _productosEnCarrito;

  static void agregarProducto(Producto producto) {
    _productosEnCarrito.add(producto);
  }

  static void eliminarProducto(Producto producto) {
    _productosEnCarrito.remove(producto);
  }

  static void limpiarCarrito() {
    _productosEnCarrito.clear();
  }
}