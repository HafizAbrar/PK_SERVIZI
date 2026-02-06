# Fingerprint Authentication Implementation

## Overview
This implementation adds fingerprint/biometric authentication to the PK Servizi app. The app now:
1. Always shows the sign-in screen after the splash screen
2. Automatically triggers fingerprint authentication for registered users
3. Allows users to authenticate using their saved credentials via biometric authentication

## Changes Made

### 1. Dependencies Added
- **local_auth: ^2.1.7** - For biometric authentication support

### 2. New Files Created
- **lib/core/services/biometric_service.dart** - Service to handle biometric authentication logic

### 3. Modified Files

#### pubspec.yaml
- Added `local_auth` package dependency

#### lib/features/auth/presentation/pages/splash_screen.dart
- Updated to always navigate to sign-in screen after splash
- Removed automatic navigation to home for authenticated users

#### lib/features/auth/presentation/pages/sign_in_screen.dart
- Added biometric authentication support
- Shows fingerprint icon when user is registered and device supports biometrics
- Auto-triggers biometric authentication on screen load for registered users
- Saves user credentials securely after successful login for future biometric authentication
- Removed the "Quick Sign In" button and replaced with automatic biometric prompt

#### android/app/src/main/AndroidManifest.xml
- Added biometric permissions:
  - `android.permission.USE_BIOMETRIC`
  - `android.permission.USE_FINGERPRINT`

#### ios/Runner/Info.plist
- Added Face ID usage description for iOS biometric authentication

## How It Works

### First Time Login
1. User opens the app → Splash screen → Sign-in screen
2. User enters email and password
3. Credentials are saved securely using FlutterSecureStorage
4. User is logged in and navigated to home

### Subsequent Logins (Registered Users)
1. User opens the app → Splash screen → Sign-in screen
2. If device supports biometrics and user has saved credentials:
   - Fingerprint icon is displayed prominently
   - Biometric authentication is automatically triggered
3. User authenticates with fingerprint/face ID
4. App retrieves saved credentials and logs in automatically
5. User can still manually enter credentials if biometric fails

## Security Features
- Credentials are stored using FlutterSecureStorage (encrypted storage)
- Biometric authentication is required to access saved credentials
- User can always fall back to manual login
- Credentials are only saved after successful login

## Testing
To test the implementation:
1. Run `flutter pub get` to install the new dependency
2. Build and run the app on a physical device (biometrics don't work well on emulators)
3. First login: Enter credentials manually
4. Close and reopen the app
5. Biometric prompt should appear automatically
6. Authenticate with fingerprint/face ID

## Platform Support
- **Android**: Fingerprint and biometric authentication (API 23+)
- **iOS**: Touch ID and Face ID
- **Web/Desktop**: Gracefully falls back to manual login

## Notes
- Biometric authentication only works on physical devices
- Users must have biometric authentication set up on their device
- The app always shows the sign-in screen after splash, ensuring security
