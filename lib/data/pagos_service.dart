import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PagosService {
  PagosService._();

  static final PagosService instance = PagosService._();

  Future<CheckoutSessionResponse> crearCheckoutSession({
    required String token,
    required List<CheckoutItem> items,
    String? descripcion,
    int? usuarioId,
  }) async {
    if (items.isEmpty) {
      throw PagosException('Tu carrito está vacío, agrega productos antes de pagar.');
    }

    final Uri url = _resolveUri(_Endpoint.crearCheckoutSession);
    final Map<String, dynamic> payload = {
      'descripcion': descripcion ?? 'Compra desde la app móvil',
      'items': items.map((item) => item.toJson()).toList(growable: false),
      if (usuarioId != null) 'usuario_id': usuarioId,
    };

    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    final dynamic data = _decodeBody(response.body);

    if (response.statusCode == 200 && data is Map<String, dynamic>) {
      return CheckoutSessionResponse.fromJson(data);
    }

    final String message = _extractMessage(data) ?? 'No fue posible iniciar el pago con Stripe.';
    throw PagosException(message);
  }

  Future<VerificacionPagoResponse> verificarPago({
    required String token,
    required String sessionId,
  }) async {
    if (sessionId.isEmpty) {
      throw PagosException('Identificador de sesión inválido.');
    }

    final Uri url = _resolveUri(
      _Endpoint.verificarPago,
      queryParameters: {'session_id': sessionId},
    );

    final response = await http.get(url, headers: _headers(token));
    final dynamic data = _decodeBody(response.body);

    if (response.statusCode == 200 && data is Map<String, dynamic>) {
      return VerificacionPagoResponse.fromJson(data);
    }

    if (response.statusCode == 400 && data is Map<String, dynamic> && data.containsKey('pago_exitoso')) {
      return VerificacionPagoResponse.fromJson(data);
    }

    final String message = _extractMessage(data) ?? 'No fue posible verificar el estado del pago.';
    throw PagosException(message);
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  dynamic _decodeBody(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final dynamic message =
          data['mensaje'] ?? data['message'] ?? data['error'] ?? data['detail'];
      return message?.toString();
    }
    return null;
  }

  Uri _resolveUri(String path, {Map<String, String>? queryParameters}) {
    final String? baseUrlEnv = dotenv.env['BASE_URL'];
    if (baseUrlEnv == null || baseUrlEnv.isEmpty) {
      throw PagosException('BASE_URL no está configurada en el archivo .env');
    }

    final String normalizedBase =
        baseUrlEnv.endsWith('/') ? baseUrlEnv : '$baseUrlEnv/';
    Uri uri = Uri.parse(normalizedBase).resolve(path);

    if (!kIsWeb && Platform.isAndroid &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      uri = uri.replace(host: '10.0.2.2');
    }

    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    return uri;
  }
}

class CheckoutItem {
  CheckoutItem({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });

  final int productoId;
  final String nombre;
  final double precio;
  final int cantidad;

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
    };
  }
}

class CheckoutSessionResponse {
  CheckoutSessionResponse({
    required this.checkoutUrl,
    required this.sessionId,
    this.total,
    this.mensaje,
  });

  factory CheckoutSessionResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionResponse(
      checkoutUrl: json['checkout_url']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      total: _parseDouble(json['total']),
      mensaje: json['mensaje']?.toString(),
    );
  }

  final String checkoutUrl;
  final String sessionId;
  final double? total;
  final String? mensaje;
}

class VerificacionPagoResponse {
  VerificacionPagoResponse({
    required this.pagoExitoso,
    this.mensaje,
    this.total,
    this.ventaId,
    this.pagoId,
  });

  factory VerificacionPagoResponse.fromJson(Map<String, dynamic> json) {
    return VerificacionPagoResponse(
      pagoExitoso: json['pago_exitoso'] == true,
      mensaje: json['mensaje']?.toString() ?? json['error']?.toString(),
      total: _parseDouble(json['total']),
      ventaId: _parseInt(json['venta_id']),
      pagoId: _parseInt(json['pago_id']),
    );
  }

  final bool pagoExitoso;
  final String? mensaje;
  final double? total;
  final int? ventaId;
  final int? pagoId;
}

class PagosException implements Exception {
  PagosException(this.message);

  final String message;

  @override
  String toString() => message;
}

double? _parseDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value == null) {
    return null;
  }
  return double.tryParse(value.toString());
}

int? _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value == null) {
    return null;
  }
  return int.tryParse(value.toString());
}

class _Endpoint {
  static const String crearCheckoutSession = 'crear-checkout-session/';
  static const String verificarPago = 'verificar-pago/';
}
