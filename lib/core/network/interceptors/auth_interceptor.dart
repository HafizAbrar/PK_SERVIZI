import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _baseUrl = 'http://10.0.2.2:3000';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Don't add token to auth endpoints
    if (options.path.contains('/auth/')) {
      handler.next(options);
      return;
    }
    
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          // Create a new Dio instance to avoid interceptor loop
          final dio = Dio();
          final response = await dio.post(
            '$_baseUrl/api/v1/auth/refresh',
            data: {'refreshToken': refreshToken},
          );
          
          final newAccessToken = response.data['data']['accessToken'];
          await _storage.write(key: 'access_token', value: newAccessToken);
          
          // Retry the original request with new token
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          
          final retryResponse = await dio.fetch(requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          // Refresh failed, clear tokens
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'refresh_token');
        }
      }
    }
    handler.next(err);
  }
}
