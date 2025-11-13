import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/venta.dart';

class PedidosService {
  PedidosService._();

  static final PedidosService instance = PedidosService._();

  Future<List<Venta>> obtenerMisPedidos({
    required String token,
    required int userId,
  }) async {
    final String? baseUrlEnv = dotenv.env['BASE_URL'];
    if (baseUrlEnv == null || baseUrlEnv.isEmpty) {
      throw Exception('BASE_URL no está configurada en el archivo .env');
    }

    final String normalizedBase =
        baseUrlEnv.endsWith('/') ? baseUrlEnv : '$baseUrlEnv/';

    final List<Map<String, dynamic>> ventasBrutas = await _fetchCollection(
      '$normalizedBase${_Endpoint.misVentas}',
      token,
      throwOnError: true,
    );

    final List<Map<String, dynamic>> ventasUsuario = ventasBrutas
        .where((venta) {
          final dynamic usuarioRaw = venta['usuario'];
          final int? usuarioId = usuarioRaw is Map<String, dynamic>
              ? _parseInt(usuarioRaw['id'])
              : _parseInt(venta['usuario_id']);

          if (kDebugMode) {
            debugPrint(
              '🔍 Venta ${venta['id']}: usuarioId=$usuarioId, usuarioActual=$userId',
            );
          }

          if (usuarioId == null) {
            return true;
          }
          return usuarioId == userId;
        })
        .map((venta) => Map<String, dynamic>.from(venta))
        .toList(growable: false);

    if (kDebugMode) {
      debugPrint(
        '📊 Ventas recibidas: ${ventasBrutas.length}, Ventas del usuario: ${ventasUsuario.length}',
      );
    }

    if (ventasUsuario.isEmpty) {
      return const [];
    }

    final List<Map<String, dynamic>> todosLosDetalles = await _fetchCollection(
      '$normalizedBase${_Endpoint.detalleVentas}',
      token,
    );
    final List<Map<String, dynamic>> todosLosPagos = await _fetchCollection(
      '$normalizedBase${_Endpoint.pagos}',
      token,
    );

    return ventasUsuario.map((venta) {
      final int ventaId = _parseInt(venta['id']) ?? 0;

      final detallesVenta = todosLosDetalles.where((detalle) {
        final dynamic ventaRaw = detalle['venta'];
        final int? detalleVentaId = ventaRaw is Map<String, dynamic>
            ? _parseInt(ventaRaw['id'])
            : _parseInt(detalle['venta_id'] ?? detalle['venta']);
        return detalleVentaId == ventaId;
      }).toList(growable: false);

      final pagosVenta = todosLosPagos.where((pago) {
        final dynamic ventaRaw = pago['venta'];
        final int? pagoVentaId = ventaRaw is Map<String, dynamic>
            ? _parseInt(ventaRaw['id'])
            : _parseInt(pago['venta_id'] ?? pago['venta']);
        return pagoVentaId == ventaId;
      }).toList(growable: false);

      final enriched = Map<String, dynamic>.from(venta)
        ..['detalles'] = detallesVenta
        ..['pagos'] = pagosVenta;

      if (kDebugMode) {
        debugPrint(
          '✅ Venta $ventaId: ${detallesVenta.length} detalles, ${pagosVenta.length} pagos',
        );
      }

      return Venta.fromJson(enriched);
    }).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _fetchCollection(
    String url,
    String token, {
    bool throwOnError = false,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Error ${response.statusCode} al obtener $url: ${response.body}',
        );
      }
      if (throwOnError) {
        final String message = _extractErrorMessage(response.body) ??
            'No fue posible obtener la información solicitada';
        throw Exception(message);
      }
      return const [];
    }

    if (response.body.isEmpty) {
      return const [];
    }

    try {
      final dynamic payload = jsonDecode(response.body);
      if (payload is List) {
        return payload.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      if (payload is Map<String, dynamic>) {
        final dynamic results = payload['results'];
        if (results is List) {
          return results
              .whereType<Map<String, dynamic>>()
              .toList(growable: false);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error parseando respuesta de $url: $e');
      }
    }

    return const [];
  }

  String? _extractErrorMessage(String responseBody) {
    if (responseBody.isEmpty) {
      return null;
    }
    try {
      final dynamic parsed = jsonDecode(responseBody);
      if (parsed is Map<String, dynamic>) {
        return parsed['detail']?.toString() ?? parsed['error']?.toString();
      }
    } catch (_) {
      // Ignorar errores de parseo
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}

class _Endpoint {
  static const String misVentas = 'mis-ventas/';
  static const String detalleVentas = 'detalleventas/';
  static const String pagos = 'pagos/';
}
