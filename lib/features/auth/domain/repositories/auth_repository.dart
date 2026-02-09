import '../../../../core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<void>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  Future<Result<Map<String, dynamic>>> login(String email, String password);
  Future<Result<void>> logout();
  Future<Result<void>> changePassword(String currentPassword, String newPassword);
  Future<Result<Map<String, dynamic>>> getCurrentUser();
}
