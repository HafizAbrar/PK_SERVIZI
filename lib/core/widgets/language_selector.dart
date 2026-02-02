import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (Locale locale) {
        ref.read(localeProvider.notifier).setLocale(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: [
              const Text('🇺🇸'),
              const SizedBox(width: 8),
              const Text('English'),
              if (currentLocale.languageCode == 'en')
                const Spacer(),
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, color: Color(0xFF186ADC)),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('it'),
          child: Row(
            children: [
              const Text('🇮🇹'),
              const SizedBox(width: 8),
              const Text('Italiano'),
              if (currentLocale.languageCode == 'it')
                const Spacer(),
              if (currentLocale.languageCode == 'it')
                const Icon(Icons.check, color: Color(0xFF186ADC)),
            ],
          ),
        ),
      ],
    );
  }
}