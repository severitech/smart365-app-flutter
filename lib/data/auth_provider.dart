import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _restoreSession();
  }

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  bool _isLoading = false;
  String? _token;
  AuthUser? _user;
  String? _lastError;

  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  AuthUser? get user => _user;
  String? get lastError => _lastError;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _lastError = null;

    try {
      final response = await AuthService.instance
          .login(email: email.trim(), password: password);
      await _persistSession(response);
      _token = response.token;
      _user = response.user;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? telefono,
    int? rolId,
  }) async {
    _setLoading(true);
    _lastError = null;

    try {
      final response = await AuthService.instance.register(
        email: email.trim(),
        password: password,
        firstName: firstName,
        lastName: lastName,
        telefono: telefono,
        rolId: rolId,
      );
      await _persistSession(response);
      _token = response.token;
      _user = response.user;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<void> _persistSession(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, response.token);
    await prefs.setString(_userKey, jsonEncode(response.user.toJson()));
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_tokenKey);
    final storedUser = prefs.getString(_userKey);

    if (storedToken != null && storedUser != null) {
      try {
        final Map<String, dynamic> userJson =
            jsonDecode(storedUser) as Map<String, dynamic>;
        _token = storedToken;
        _user = AuthUser.fromJson(userJson);
        notifyListeners();
      } catch (e) {
        await prefs.remove(_tokenKey);
        await prefs.remove(_userKey);
        if (kDebugMode) {
          print('Error restaurando la sesión: $e');
        }
      }
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
