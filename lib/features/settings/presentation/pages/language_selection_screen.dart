import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  final bool isFirstTime;
  const LanguageSelectionScreen({super.key, this.isFirstTime = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: isFirstTime ? null : AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: Text(l10n.selectLanguage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (isFirstTime) const SizedBox(height: 60),
          Text(
            l10n.selectLanguage,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 24),
          _buildLanguageOption(context, ref, 'English', 'en', '🇬🇧', currentLocale.languageCode == 'en'),
          const SizedBox(height: 12),
          _buildLanguageOption(context, ref, 'Italiano', 'it', '🇮🇹', currentLocale.languageCode == 'it'),
          const SizedBox(height: 12),
          _buildLanguageOption(context, ref, 'Français', 'fr', '🇫🇷', currentLocale.languageCode == 'fr'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, String language, String code, String flag, bool isSelected) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        await ref.read(languageProvider.notifier).setLanguage(Locale(code));
        if (context.mounted) {
          if (isFirstTime) {
            context.go('/login');
          } else {
            final message = code == 'en' 
                ? 'Language changed to English'
                : code == 'it'
                ? 'Lingua cambiata in Italiano'
                : 'Langue changée en Français';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFF2D00D) : Colors.grey[200]!, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(child: Text(language, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            if (isSelected) const Icon(Icons.check, color: Color(0xFFF2D00D)),
          ],
        ),
      ),
    );
  }
}
