import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  static const _storage = FlutterSecureStorage();
  
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final languageCode = await _storage.read(key: 'language_code');
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLanguage(Locale locale) async {
    state = locale;
    await _storage.write(key: 'language_code', value: locale.languageCode);
  }
}