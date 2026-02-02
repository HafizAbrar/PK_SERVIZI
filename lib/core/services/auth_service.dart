import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String baseUrl = 'https://api.pkservizi.com';

  AuthService(this._dio);

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'access_token', value: data['accessToken']);
        await _storage.write(key: 'refresh_token', value: data['refreshToken']);
        return data;
      }
      throw Exception('Failed to refresh token');
    } catch (e) {
      throw Exception('Refresh token failed: $e');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/auth/forgot-password',
        data: {'email': email},
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to send password reset');
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }
  Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/auth/reset-password',
        data: {
          'token': token,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to reset password');
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('$baseUrl/api/v1/auth/logout');
      
      if (response.statusCode == 200) {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
        return response.data;
      }
      throw Exception('Failed to logout');
    } catch (e) {
      // Clear tokens even if API call fails
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      throw Exception('Logout failed: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/auth/me');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to get user info');
    } catch (e) {
      throw Exception('Get user info failed: $e');
    }
  }
}