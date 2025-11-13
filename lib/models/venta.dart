class Venta {
  Venta({
    required this.id,
    required this.fecha,
    required this.total,
    required this.estado,
    this.detalles = const [],
    this.pagos = const [],
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? detallesJson = json['detalles'] as List<dynamic>?;
    final List<dynamic>? pagosJson = json['pagos'] as List<dynamic>?;

    return Venta(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      fecha: _parseDate(json['fecha']),
      total: _parseDouble(json['total']),
      estado: json['estado']?.toString() ?? 'Desconocido',
      detalles: detallesJson == null
          ? const []
          : detallesJson
              .whereType<Map<String, dynamic>>()
              .map(DetalleVenta.fromJson)
              .toList(growable: false),
      pagos: pagosJson == null
          ? const []
          : pagosJson
              .whereType<Map<String, dynamic>>()
              .map(PagoVenta.fromJson)
              .toList(growable: false),
    );
  }

  final int id;
  final DateTime? fecha;
  final double total;
  final String estado;
  final List<DetalleVenta> detalles;
  final List<PagoVenta> pagos;

  static DateTime? _parseDate(dynamic raw) {
    if (raw is DateTime) {
      return raw;
    }
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw.toString());
  }

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
          : int.tryParse('${json['cantidad']}') ?? 0,
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

class PagoVenta {
  PagoVenta({
    required this.id,
    required this.monto,
    required this.fecha,
    this.stripeKey,
  });

  factory PagoVenta.fromJson(Map<String, dynamic> json) {
    return PagoVenta(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      monto: Venta._parseDouble(json['monto']),
      fecha: Venta._parseDate(json['fecha']),
      stripeKey: json['stripe_key']?.toString(),
    );
  }

  final int id;
  final double monto;
  final DateTime? fecha;
  final String? stripeKey;
}
