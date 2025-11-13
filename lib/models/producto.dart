// Mover este archivo a la carpeta `data` para organizar los datos.
class Producto {
  final String descripcion;
  final double precio;
  final int stock;
  final List<String> imagenes;
  final String estado;

  Producto({
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imagenes,
    required this.estado,
  });
}