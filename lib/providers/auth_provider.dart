import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService}) : _auth = authService ?? AuthService();

  final AuthService _auth;

  /// Exposed so DataProvider can reuse the same authenticated client.
  AuthService get authService => _auth;

  User? user;
  bool bootstrapping = true;

  Future<void> restore() async {
    user = await _auth.restoreSession();
    bootstrapping = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      user = await _auth.login(email, password);
      notifyListeners();
      return true;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Could not sign in. Check your connection and try again.');
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    user = null;
    notifyListeners();
  }
}
