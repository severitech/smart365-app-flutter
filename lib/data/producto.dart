import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Producto {
  final int id;
  final String descripcion;
  final double precio;
  final int stock;
  final List<String> imagenes;
  final String estado;
  final int? subcategoriaId;
  final String? subcategoriaNombre;
  final int? categoriaId;
  final String? categoriaNombre;

  Producto({
    required this.id,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imagenes,
    required this.estado,
    this.subcategoriaId,
    this.subcategoriaNombre,
    this.categoriaId,
    this.categoriaNombre,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    final dynamic precioRaw = json['precio'] ?? 0;
    final dynamic stockRaw = json['stock'] ?? 0;
  final dynamic subcategoriaDynamic = json['subcategoria'];
  final Map<String, dynamic>? subcategoriaRaw =
    subcategoriaDynamic is Map<String, dynamic> ? subcategoriaDynamic : null;

  final dynamic categoriaDynamic = subcategoriaRaw?['categoria'];
  final Map<String, dynamic>? categoriaRaw =
    categoriaDynamic is Map<String, dynamic> ? categoriaDynamic : null;

    return Producto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      descripcion: json['descripcion']?.toString() ?? '',
      precio: (precioRaw is num) ? precioRaw.toDouble() : double.tryParse('$precioRaw') ?? 0.0,
      stock: (stockRaw is num) ? stockRaw.toInt() : int.tryParse('$stockRaw') ?? 0,
      imagenes: (json['imagenes'] as List<dynamic>?)?.map((img) => img.toString()).toList() ?? <String>[],
      estado: json['estado']?.toString() ?? 'Desconocido',
    subcategoriaId: subcategoriaRaw == null
      ? null
      : (subcategoriaRaw['id'] is int
        ? subcategoriaRaw['id'] as int
        : int.tryParse('${subcategoriaRaw['id']}')),
      subcategoriaNombre: subcategoriaRaw?['descripcion']?.toString(),
    categoriaId: categoriaRaw == null
      ? null
      : (categoriaRaw['id'] is int
        ? categoriaRaw['id'] as int
        : int.tryParse('${categoriaRaw['id']}')),
      categoriaNombre: categoriaRaw?['descripcion']?.toString(),
    );
  }

  static Future<List<Producto>> fetchProductos({
    String? overrideBaseUrl,
    Map<String, String>? queryParameters,
  }) async {
    final result = await fetchProductosWithRaw(
      overrideBaseUrl: overrideBaseUrl,
      queryParameters: queryParameters,
    );
    return result.productos;
  }

  static Future<FetchProductosResult> fetchProductosWithRaw({
    String? overrideBaseUrl,
    Map<String, String>? queryParameters,
  }) async {
    final String? baseUrlEnv = overrideBaseUrl ?? dotenv.env['BASE_URL'];
    if (baseUrlEnv == null || baseUrlEnv.isEmpty) {
      throw Exception('BASE_URL no está configurada en el archivo .env');
    }

    final String normalizedBase = baseUrlEnv.endsWith('/') ? baseUrlEnv : '$baseUrlEnv/';
    Uri requestUri = Uri.parse(normalizedBase).resolve('productos/');

    if (!kIsWeb && Platform.isAndroid &&
        (requestUri.host == 'localhost' || requestUri.host == '127.0.0.1')) {
      requestUri = requestUri.replace(host: '10.0.2.2');
    }

    final filteredQueryParameters = queryParameters == null
        ? <String, String>{}
        : {
            for (final entry in queryParameters.entries)
              if (entry.value.trim().isNotEmpty) entry.key: entry.value,
          };

    if (filteredQueryParameters.isNotEmpty) {
      requestUri = requestUri.replace(queryParameters: filteredQueryParameters);
    }

    debugPrint('Realizando petición a: ${requestUri.toString()}');
    final response = await http.get(requestUri);
    debugPrint('Estado de la respuesta: ${response.statusCode}');
    debugPrint('Cuerpo de la respuesta: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      final List<dynamic> listaProductos;

      if (decoded is List<dynamic>) {
        listaProductos = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final dynamic posibleLista =
            decoded['results'] ?? decoded['data'] ?? decoded['items'];
        if (posibleLista is List<dynamic>) {
          listaProductos = posibleLista;
        } else {
          throw Exception(
            'Formato de respuesta inesperado: se esperaba una lista de productos',
          );
        }
      } else {
        throw Exception(
          'Formato de respuesta desconocido: se esperaba JSON tipo lista o mapa',
        );
      }

      final productosParseados =
          listaProductos.map((json) => Producto.fromJson(json)).toList();
      return FetchProductosResult(
        productos: productosParseados,
        rawBody: response.body,
        requestUri: requestUri,
      );
    }

    throw Exception(
      'Error al cargar los productos (status ${response.statusCode}): ${response.body}',
    );
  }

  String get imagen => imagenes.isNotEmpty ? imagenes.first : '';
  String get nombre => descripcion;
  int get cantidad => stock;
}

class FetchProductosResult {
  FetchProductosResult({
    required this.productos,
    required this.rawBody,
    required this.requestUri,
  });

  final List<Producto> productos;
  final String rawBody;
  final Uri requestUri;
}