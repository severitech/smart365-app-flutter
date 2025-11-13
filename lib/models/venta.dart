class Venta {
  Venta({
    required this.id,
    required this.fecha,
    required this.total,
    required this.estado,
    this.detalles = const [],
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? detallesJson = json['detalles'] as List<dynamic>?;

    return Venta(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? ''),
      total: _parseDouble(json['total']),
      estado: json['estado']?.toString() ?? 'Desconocido',
      detalles: detallesJson == null
          ? const []
          : detallesJson
              .map((detalle) => DetalleVenta.fromJson(
                    detalle as Map<String, dynamic>,
                  ))
              .toList(growable: false),
    );
  }

  final int id;
  final DateTime? fecha;
  final double total;
  final String estado;
  final List<DetalleVenta> detalles;

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}

class DetalleVenta {
  DetalleVenta({
    required this.id,
    required this.cantidad,
    required this.subtotal,
    this.productoNombre,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      cantidad: json['cantidad'] is int
          ? json['cantidad'] as int
          : int.tryParse('${json['cantidad']}') ??
              0,
      subtotal: Venta._parseDouble(json['subtotal']),
      productoNombre: _parseProductName(json['producto']),
    );
  }

  final int id;
  final int cantidad;
  final double subtotal;
  final String? productoNombre;

  static String? _parseProductName(dynamic rawProducto) {
    if (rawProducto is Map<String, dynamic>) {
      return rawProducto['descripcion']?.toString();
    }
    if (rawProducto == null) {
      return null;
    }
    return rawProducto.toString();
  }
}
