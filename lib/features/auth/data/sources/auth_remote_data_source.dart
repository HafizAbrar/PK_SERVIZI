import 'package:dio/dio.dart';
import '../models/register_request_dto.dart';
import '../../../../core/errors/app_exception.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register(RegisterRequestDto request);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<Map<String, dynamic>> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> register(RegisterRequestDto request) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/register',
        data: request.toJson(),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Registration failed';
        if (message.contains('Operation could not be completed')) {
          throw ValidationException('User already exists with this email');
        }
        throw ValidationException(message);
      } else if (e.response?.statusCode == 409) {
        throw ValidationException('User already exists');
      }
      throw NetworkException('Registration failed');
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ValidationException('Incorrect email or Password!');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Login failed';
        throw ValidationException(message);
      }
      throw NetworkException('Login failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/api/v1/auth/logout');
    } on DioException {
      throw NetworkException('Logout failed');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.post(
        '/api/v1/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Password change failed';
        throw ValidationException(message);
      }
      throw NetworkException('Password change failed');
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/v1/auth/me');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw NetworkException('Failed to get user info');
    }
  }
}
