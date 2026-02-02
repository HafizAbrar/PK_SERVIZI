# Theme Configuration Guide

## Quick Color Change

To change the app's color scheme, edit the colors in `lib/core/theme/app_theme.dart`:

### Primary Colors
```dart
static const Color primaryColor = Color(0xFF1B5E20);     // Main brand color
static const Color primaryLight = Color(0xFF4CAF50);     // Lighter variant
static const Color primaryDark = Color(0xFF0D4E12);      // Darker variant
```

### Common Color Schemes

#### Blue Theme
```dart
static const Color primaryColor = Color(0xFF1976D2);
static const Color primaryLight = Color(0xFF42A5F5);
static const Color primaryDark = Color(0xFF0D47A1);
```

#### Purple Theme
```dart
static const Color primaryColor = Color(0xFF7B1FA2);
static const Color primaryLight = Color(0xFFBA68C8);
static const Color primaryDark = Color(0xFF4A148C);
```

#### Orange Theme
```dart
static const Color primaryColor = Color(0xFFE65100);
static const Color primaryLight = Color(0xFFFF9800);
static const Color primaryDark = Color(0xFFBF360C);
```

#### Red Theme
```dart
static const Color primaryColor = Color(0xFFD32F2F);
static const Color primaryLight = Color(0xFFEF5350);
static const Color primaryDark = Color(0xFFB71C1C);
```

## Customizable Elements

- **Colors**: Primary, secondary, status colors
- **Spacing**: Margins, paddings, gaps
- **Border Radius**: Button, card, input field corners
- **Font Sizes**: Text sizes throughout the app
- **Shadows**: Card and button shadows
- **Button Styles**: Primary and secondary button appearance

## How to Apply Changes

1. Edit `lib/core/theme/app_theme.dart`
2. Run `flutter hot reload` to see changes instantly
3. No need to rebuild the entire app

## Brand Customization

Replace logo files in `assets/logos/` with client's brand assets while keeping the same filenames.