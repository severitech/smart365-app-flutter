import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PushService {
  static final PushService instance = PushService._internal();

  PushService._internal();

  late final FirebaseMessaging _messaging;

  /// Inicializa Firebase Messaging, registra token y escucha refresh.
  Future<void> init() async {
    _messaging = FirebaseMessaging.instance;

    // Request permissions where applicable
    await _messaging.requestPermission();

    // Get current token and send to backend if user is authenticated
    try {
      final token = await _messaging.getToken();
      if (token != null) await _sendTokenToBackend(token);
    } catch (e) {
      debugPrint('Error obteniendo token FCM: $e');
    }

    // Listen for token refresh and re-send
    _messaging.onTokenRefresh.listen((newToken) async {
      try {
        await _sendTokenToBackend(newToken);
      } catch (e) {
        debugPrint('Error re-enviando token refrescado: $e');
      }
    });

    // Foreground messages (simple logging default)
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground FCM message: ${message.notification?.title}');
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    if (authToken == null || authToken.isEmpty) {
      debugPrint('PushService: no hay auth token, se omite registro del token');
      return;
    }

    final base = dotenv.env['BASE_URL'] ?? '';
    if (base.isEmpty) {
      debugPrint('PushService: BASE_URL no configurado en .env');
      return;
    }

    final url = Uri.parse('$base/devices/register/');
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: jsonEncode({
        'registration_id': token,
        'tipo_dispositivo': 'android',
      }),
    );

    if (resp.statusCode >= 400) {
      debugPrint(
        'PushService: fallo al registrar token (${resp.statusCode}): ${resp.body}',
      );
    } else {
      debugPrint('PushService: token registrado correctamente');
    }
  }

  /// Llama al endpoint de unregister usando el token actual del dispositivo.
  Future<void> unregister() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    if (authToken == null || authToken.isEmpty) {
      debugPrint('PushService: no hay auth token, se omite unregister');
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      debugPrint('PushService: token FCM null en unregister');
      return;
    }

    final base = dotenv.env['BASE_URL'] ?? '';
    if (base.isEmpty) {
      debugPrint('PushService: BASE_URL no configurado en .env');
      return;
    }

    final url = Uri.parse('$base/devices/unregister/');
    try {
      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
        body: jsonEncode({'registration_id': token}),
      );

      if (resp.statusCode >= 400) {
        debugPrint(
          'PushService: fallo al unregister (${resp.statusCode}): ${resp.body}',
        );
      } else {
        debugPrint('PushService: unregister enviado correctamente');
      }
    } catch (e) {
      debugPrint('PushService: error en unregister: $e');
    }
  }
}
