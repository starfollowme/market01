import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final _dio = ApiClient.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    await _saveToken(res.data['token']);
    return res.data;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    await _saveToken(res.data['token']);
    return res.data;
  }

  Future<UserModel> getMe() async {
    final res = await _dio.get('/me');
    return UserModel.fromJson(res.data);
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
