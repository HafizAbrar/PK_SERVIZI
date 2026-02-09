import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      // Error checking biometric: $e
      return false;
    }
  }

  Future<bool> isUserRegistered() async {
    final email = await _storage.read(key: 'saved_email');
    return email != null;
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final email = await _storage.read(key: 'saved_email');
    final password = await _storage.read(key: 'saved_password');
    
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } catch (e) {
      // Error authenticating: $e
      return false;
    }
  }
}
