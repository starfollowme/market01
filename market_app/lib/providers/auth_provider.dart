import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<void> checkAuth() async {
    final token = await _service.getToken();
    if (token != null) {
      try {
        _user = await _service.getMe();
        notifyListeners();
      } catch (_) {
        _user = null;
      }
    }
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _service.login(phone, password);
      _user = UserModel.fromJson(data);
      return true;
    } catch (e) {
      _error = _parseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String phone, String password, String confirm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _service.register(name, phone, password, confirm);
      _user = UserModel.fromJson(data);
      return true;
    } catch (e) {
      _error = _parseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    try {
      final errors = e.response?.data['errors'];
      if (errors != null) {
        return (errors as Map).values.first[0].toString();
      }
      return e.response?.data['message'] ?? 'Terjadi kesalahan.';
    } catch (_) {
      return 'Tidak dapat terhubung ke server.';
    }
  }
}
