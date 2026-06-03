import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final _dio = ApiClient.instance;

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final res = await _dio.post('/login', data: {
      'phone': phone,
      'password': password,
    });
    
    if (res.data['success'] == true) {
      await _saveToken(res.data['data']['token']);
      return res.data['data']['user'];
    } else {
      throw Exception(res.data['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String phone, String password, String passwordConfirmation) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    
    if (res.data['success'] == true) {
      await _saveToken(res.data['data']['token']);
      return res.data['data']['user'];
    } else {
      throw Exception(res.data['message'] ?? 'Registration failed');
    }
  }

  Future<UserModel> getMe() async {
    final res = await _dio.get('/me');
    if (res.data['success'] == true) {
      return UserModel.fromJson(res.data['data']);
    } else {
      throw Exception('Failed to get user');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } on DioException {
      // token mungkin sudah expired
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
}
