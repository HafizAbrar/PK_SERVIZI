import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final isAvailable = await canUseBiometric();
      if (!isAvailable) {
        print('Biometric not available');
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      print('Platform exception: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Error authenticating: $e');
      return false;
    }
  }

  Future<bool> isUserRegistered() async {
    final email = await _storage.read(key: 'saved_email');
    print('User registered check: ${email != null}');
    return email != null;
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final email = await _storage.read(key: 'saved_email');
    final password = await _storage.read(key: 'saved_password');
    
    print('Saved credentials - Email: ${email != null}, Password: ${password != null}');
    
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }
}
