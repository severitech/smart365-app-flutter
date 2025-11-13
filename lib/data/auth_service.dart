import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final String? baseUrlEnv = dotenv.env['BASE_URL'];
    if (baseUrlEnv == null || baseUrlEnv.isEmpty) {
      throw Exception('BASE_URL no está configurada en el archivo .env');
    }

    final String normalizedBase =
        baseUrlEnv.endsWith('/') ? baseUrlEnv : '$baseUrlEnv/';
    final Uri url = Uri.parse('${normalizedBase}authz/login/');

    final response = await http.post(
      url,
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final Map<String, dynamic> payload = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(payload);
    }

    final String message =
        payload['error']?.toString() ?? 'Error ${response.statusCode} al iniciar sesión';
    throw Exception(message);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? telefono,
    int? rolId,
  }) async {
    final String? baseUrlEnv = dotenv.env['BASE_URL'];
    if (baseUrlEnv == null || baseUrlEnv.isEmpty) {
      throw Exception('BASE_URL no está configurada en el archivo .env');
    }

    final String normalizedBase =
        baseUrlEnv.endsWith('/') ? baseUrlEnv : '$baseUrlEnv/';
    final Uri url = Uri.parse('${normalizedBase}authz/register/');

    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
    };

    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (telefono != null) body['telefono'] = telefono;
    if (rolId != null) body['rol'] = rolId;

    final response = await http.post(
      url,
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final Map<String, dynamic> payload = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return AuthResponse.fromJson(payload);
    }

    final String message =
        payload['error']?.toString() ?? 'Error ${response.statusCode} al registrar usuario';
    throw Exception(message);
  }
}

class AuthResponse {
  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token']?.toString() ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String token;
  final AuthUser user;
}

class AuthUser {
  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profile,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      profile: json['perfil'] is Map<String, dynamic>
          ? UserProfile.fromJson(json['perfil'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'perfil': profile?.toJson(),
    };
  }

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final UserProfile? profile;
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.user,
    required this.rol,
    required this.telefono,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      user: json['user']?.toString() ?? '',
      rol: json['rol']?.toString(),
      telefono: json['telefono']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'rol': rol,
      'telefono': telefono,
    };
  }

  final int id;
  final String user;
  final String? rol;
  final String? telefono;
}
