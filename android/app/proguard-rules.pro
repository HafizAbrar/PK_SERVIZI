# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Stripe
-keep class com.stripe.** { *; }
-keep interface com.stripe.** { *; }
-dontwarn com.stripe.**

# WebView
-keep class android.webkit.** { *; }
-keep interface android.webkit.** { *; }

# Dio
-keep class io.dio.** { *; }
-keep class com.google.gson.** { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
