import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class TranslationService {
  static final _cache = <String, String>{};
  static final _dio = Dio();
  
  // Using Google Translate API
  static const _apiUrl = 'https://translate.googleapis.com/translate_a/single';
  
  // Translate text from backend
  static Future<String> translate(String text, String targetLang, {String sourceLang = 'it'}) async {
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
      // Call Google Translate API
      final response = await _dio.get(
        _apiUrl,
        queryParameters: {
          'client': 'gtx',
          'sl': sourceLang,
          'tl': targetLang,
          'dt': 't',
          'q': text,
        },
      );
      
      final translated = response.data[0][0][0] ?? text;
      
      // Cache the result
      _cache[cacheKey] = translated;
      await prefs.setString(cacheKey, translated);
      
      return translated;
    } catch (e) {
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
    
    // Translate from Italian to target language
    if (text.isNotEmpty && locale != 'it') {
      return await translate(text, locale, sourceLang: 'it');
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
