# Performance Optimization Guide

## Immediate Fixes:

### 1. Clean Build Cache
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
```

### 2. Optimize Gradle Settings
Add to `android/gradle.properties`:
```
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.daemon=true
```

### 3. Reduce Debug Overhead
In `lib/main.dart`, wrap expensive operations:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kDebugMode) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### 4. Lazy Load Heavy Dependencies
Move heavy initializations to when actually needed instead of main().

### 5. Build Release Version
```bash
flutter build apk --release
# or
flutter run --release
```

## Root Causes of Slowness:
- JVM crashes requiring restarts
- Debug mode overhead
- Heavy plugin initialization
- Gradle build cache issues