import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/venta.dart';

class PedidosService {
  PedidosService._();

  static final PedidosService instance = PedidosService._();

  Future<List<Venta>> obtenerMisPedidos({required String token}) async {
    final String? baseUrlEnv = dotenv.env['BASE_URL'];
    if (baseUrlEnv == null || baseUrlEnv.isEmpty) {
      throw Exception('BASE_URL no está configurada en el archivo .env');
    }

    final String normalizedBase =
        baseUrlEnv.endsWith('/') ? baseUrlEnv : '$baseUrlEnv/';
    final Uri url = Uri.parse('${normalizedBase}mis-ventas/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> payload = response.body.isEmpty
          ? const []
          : jsonDecode(response.body) as List<dynamic>;
      return payload
          .whereType<Map<String, dynamic>>()
          .map((data) => Venta.fromJson(data))
          .toList(growable: false);
    }

    String message = 'No fue posible obtener los pedidos';
    if (response.body.isNotEmpty) {
      try {
        final dynamic errorBody = jsonDecode(response.body);
        if (errorBody is Map<String, dynamic>) {
          message = errorBody['detail']?.toString() ?? message;
        }
      } catch (_) {
        // Ignorar errores de parseo: mantenemos el mensaje por defecto
      }
    }
    throw Exception(message);
  }
}
