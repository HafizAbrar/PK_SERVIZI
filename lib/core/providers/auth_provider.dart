import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

final refreshTokenProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, refreshToken) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.refreshToken(refreshToken);
});

final forgotPasswordProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, email) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.forgotPassword(email);
});

final resetPasswordProvider = FutureProvider.family<Map<String, dynamic>, Map<String, String>>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.resetPassword(params['token']!, params['password']!);
});

final logoutProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.logout();
});

final getCurrentUserProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
});