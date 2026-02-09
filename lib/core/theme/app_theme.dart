import 'package:flutter/material.dart';

class AppTheme {
  // Executive color scheme from HTML design
  static const Color primaryColor = Color(0xFF0A1D37);
  static const Color accentColor = Color(0xFF1E3A5F);
  static const Color goldLight = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFF996515);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0A1D37);
  
  // Legacy colors for compatibility
  static const Color secondaryColor = Color(0xFF1E3A5F);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  
  static const Color textPrimary = Color(0xFF111418);
  static const Color textSecondary = Color(0xFF637288);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFF3F4F6);

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Font sizes
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;

  // Border radius
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 24.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    border: Border.all(color: borderColor),
  );

  // Button styles - Executive design
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 8,
    shadowColor: primaryColor.withValues(alpha: 0.2),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: primaryColor,
    side: BorderSide(color: const Color(0xFFE2E8F0)),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  );

  // Input decoration - Executive design
  static InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: goldLight.withValues(alpha: 0.4)),
    ),
  );
  
  // PK Logo Widget
  static Widget buildPKLogo({double size = 96}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1D37), Color(0xFF1E3A5F)],
        ),
        borderRadius: BorderRadius.circular(size * 0.208),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(size * 0.208),
            ),
          ),
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFF996515)],
              ).createShader(bounds),
              child: Text(
                'PK',
                style: TextStyle(
                  fontSize: size * 0.375,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // PK Branding Text
  static Widget buildPKBranding({String? excellenceText}) {
    return Column(
      children: [
        const Text(
          'PK SERVIZI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 6,
            color: Color(0xFF0A1D37),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 1, width: 24, color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
            const SizedBox(width: 12),
            Text(
              excellenceText ?? 'EXCELLENCE IN FISCAL CARE',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Color(0xFF996515),
              ),
            ),
            const SizedBox(width: 12),
            Container(height: 1, width: 24, color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
          ],
        ),
      ],
    );
  }
}
