import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/sources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// Dio provider
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(apiClientProvider).dio;
});

// Data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthStateInitial());

  bool get isLoading => state is AuthStateLoading;
  bool get isAuthenticated => state is AuthStateAuthenticated;

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String fiscalCode,
    required String phone,
    required String dateOfBirth,
    required String address,
    required String city,
    required String postalCode,
    required String province,
    required bool gdprConsent,
    required bool marketingConsent,
  }) async {
    state = const AuthStateLoading();

    final result = await _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      fiscalCode: fiscalCode,
      phone: phone,
      dateOfBirth: dateOfBirth,
      address: address,
      city: city,
      postalCode: postalCode,
      province: province,
      gdprConsent: gdprConsent,
      marketingConsent: marketingConsent,
    );

    switch (result) {
      case Success():
        state = const AuthStateRegisterSuccess();
      case Failure(message: final message):
        state = AuthStateError(message);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();

    // Clear any existing tokens first
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    final result = await _repository.login(email, password);

    switch (result) {
      case Success(data: final tokenData):
        await _storeTokens(tokenData);
        state = const AuthStateLoginSuccess();
      case Failure(message: final message):
        state = AuthStateError(message);
    }
  }

  Future<void> logout() async {
    state = const AuthStateLoading();
    
    final result = await _repository.logout();
    
    // Clear tokens regardless of API call result
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    
    switch (result) {
      case Success():
        state = const AuthStateLoggedOut();
      case Failure():
        // Still consider logout successful locally
        state = const AuthStateLoggedOut();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = const AuthStateLoading();
    
    final result = await _repository.changePassword(currentPassword, newPassword);
    
    switch (result) {
      case Success():
        state = const AuthStatePasswordChanged();
      case Failure(message: final message):
        state = AuthStateError(message);
    }
  }

  Future<void> getCurrentUser() async {
    state = const AuthStateLoading();
    
    final result = await _repository.getCurrentUser();
    
    switch (result) {
      case Success(data: final userData):
        state = AuthStateUserLoaded(userData);
      case Failure(message: final message):
        state = AuthStateError(message);
    }
  }

  Future<void> _storeTokens(Map<String, dynamic> tokenData) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'access_token', value: tokenData['accessToken']);
    await storage.write(key: 'refresh_token', value: tokenData['refreshToken']);
  }
}

sealed class AuthState {
  const AuthState();
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final String token;
  const AuthStateAuthenticated(this.token);
}

class AuthStateRegisterSuccess extends AuthState {
  const AuthStateRegisterSuccess();
}

class AuthStateLoginSuccess extends AuthState {
  const AuthStateLoginSuccess();
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

class AuthStatePasswordChanged extends AuthState {
  const AuthStatePasswordChanged();
}

class AuthStateUserLoaded extends AuthState {
  final Map<String, dynamic> userData;
  const AuthStateUserLoaded(this.userData);
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}
