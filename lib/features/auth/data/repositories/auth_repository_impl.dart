import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_data_source.dart';
import '../models/register_request_dto.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> register({
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
    try {
      final request = RegisterRequestDto(
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

      await _remoteDataSource.register(request);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return Failure('Registration failed', exception: Exception(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      return Success(response['data']);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return Failure('Login failed', exception: Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return Failure('Logout failed', exception: Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> changePassword(String currentPassword, String newPassword) async {
    try {
      await _remoteDataSource.changePassword(currentPassword, newPassword);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return Failure('Password change failed', exception: Exception(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _remoteDataSource.getCurrentUser();
      return Success(response['data']);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return Failure('Failed to get user info', exception: Exception(e.toString()));
    }
  }
}
