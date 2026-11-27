import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_service.dart';

/// Handles the JWT session: login, restore on app start, logout.
/// The token lives in shared storage; the profile comes from GET /me.
class AuthService {
  AuthService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;
  static const _tokenKey = 'auth.jwt';
  static const _userKey = 'auth.user';

  ApiService get api => _api;

  Future<User> login(String email, String password) async {
    final res = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final map = res as Map<String, dynamic>;
    if (map['status'] != 'ok') {
      throw AuthException(map['message'] as String? ?? 'Login failed');
    }
    final token = map['token'] as String;
    final user = User.fromJson((map['me'] ?? {}) as Map<String, dynamic>);

    _api.applyToken(token);
    await _persist(token, user);
    return user;
  }

  /// Restores a previous session from storage and validates the token
  /// against the backend. Returns null when there is nothing valid.
  Future<User?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;

    _api.applyToken(token);
    try {
      final res = await _api.get('/me');
      final user = User.fromJson(res as Map<String, dynamic>);
      await _persist(token, user);
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _persist(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
