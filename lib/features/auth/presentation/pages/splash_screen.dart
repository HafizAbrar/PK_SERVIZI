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

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _initialize();
  }

  _initialize() async {
    await Future.delayed(const Duration(seconds: 3));
    
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(1500),
                  child: Image.asset(
                    'assets/logos/APP LOGO.jpeg',
                    width: 300,
                    height: 100,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(height: 24),
                AppTheme.buildPKBranding(
                  excellenceText: l10n?.excellenceInFiscalCare,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
