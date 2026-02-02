import '../../../../core/utils/result.dart';

abstract class AuthRepository {
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
  });

  Future<Result<Map<String, dynamic>>> login(String email, String password);
  Future<Result<void>> logout();
  Future<Result<void>> changePassword(String currentPassword, String newPassword);
  Future<Result<Map<String, dynamic>>> getCurrentUser();
}
