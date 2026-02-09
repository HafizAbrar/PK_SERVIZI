import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/language_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final languageNotifier = ref.read(languageProvider.notifier);
      final isLanguageSelected = await languageNotifier.isLanguageSelected();
      
      if (isLanguageSelected) {
        context.go('/login');
      } else {
        context.go('/language-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTheme.buildPKLogo(size: 120),
            const SizedBox(height: 24),
            AppTheme.buildPKBranding(
              excellenceText: l10n?.excellenceInFiscalCare,
            ),
          ],
        ),
      ),
    );
  }
}
