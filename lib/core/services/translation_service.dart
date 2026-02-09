import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class TranslationService {
  static final _cache = <String, String>{};
  static final _dio = Dio();
  
  // Google Translate API endpoint (free alternative: LibreTranslate)
  static const _apiUrl = 'https://libretranslate.com/translate';
  
  // Translate text from backend
  static Future<String> translate(String text, String targetLang, {String sourceLang = 'auto'}) async {
    if (text.isEmpty) return text;
    
    final cacheKey = '$text-$sourceLang-$targetLang';
    
    // Check memory cache
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    
    // Check persistent cache
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      _cache[cacheKey] = cached;
      return cached;
    }
    
    try {
      // Call LibreTranslate API (free, no API key needed)
      final response = await _dio.post(
        _apiUrl,
        data: {
          'q': text,
          'source': sourceLang,
          'target': targetLang,
          'format': 'text',
        },
      );
      
      final translated = response.data['translatedText'] ?? text;
      
      // Cache the result
      _cache[cacheKey] = translated;
      await prefs.setString(cacheKey, translated);
      
      return translated;
    } catch (e) {
      // Return original text on error
      return text;
    }
  }
  
  // Get translation based on current locale
  static Future<String> getTranslation(BuildContext context, dynamic backendText) async {
    if (backendText is Map) {
      final locale = Localizations.localeOf(context).languageCode;
      return backendText[locale] ?? backendText['en'] ?? backendText.values.first ?? '';
    }
    
    final text = backendText?.toString() ?? '';
    final locale = Localizations.localeOf(context).languageCode;
    
    // Only translate if not English and text is not empty
    if (locale != 'en' && text.isNotEmpty) {
      return await translate(text, locale);
    }
    
    return text;
  }
  
  // Synchronous version (returns cached or original)
  static String getTranslationSync(BuildContext context, dynamic backendText) {
    if (backendText is Map) {
      final locale = Localizations.localeOf(context).languageCode;
      return backendText[locale] ?? backendText['en'] ?? backendText.values.first ?? '';
    }
    
    final text = backendText?.toString() ?? '';
    final locale = Localizations.localeOf(context).languageCode;
    final cacheKey = '$text-auto-$locale';
    
    return _cache[cacheKey] ?? text;
  }
  
  // Clear cache
  static Future<void> clearCache() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.contains('-'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
