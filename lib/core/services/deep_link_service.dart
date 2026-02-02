import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeepLinkService {
  static const MethodChannel _channel = MethodChannel('pk_servizi/deep_links');
  
  /// Initialize deep link handling
  static Future<void> initialize() async {
    try {
      _channel.setMethodCallHandler(_handleDeepLink);
    } catch (e) {
      debugPrint('Error initializing deep links: $e');
    }
  }
  
  /// Handle incoming deep links
  static Future<void> _handleDeepLink(MethodCall call) async {
    if (call.method == 'handleDeepLink') {
      final String? url = call.arguments as String?;
      if (url != null) {
        await _processDeepLink(url);
      }
    }
  }
  
  /// Process deep link URL
  static Future<void> _processDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      debugPrint('Processing deep link: $url');
      
      // Extract requestId and serviceId from URL
      final requestId = uri.queryParameters['requestId'];
      final serviceId = uri.queryParameters['serviceId'];
      
      debugPrint('Extracted requestId: $requestId, serviceId: $serviceId');
      
      // Store the deep link data for later processing
      if (requestId != null) {
        await _storeDeepLinkData(requestId, serviceId);
      }
    } catch (e) {
      debugPrint('Error processing deep link: $e');
    }
  }
  
  /// Store deep link data for later processing
  static Future<void> _storeDeepLinkData(String requestId, String? serviceId) async {
    // You can use SharedPreferences or another storage method here
    debugPrint('Storing deep link data - requestId: $requestId, serviceId: $serviceId');
  }
  
  /// Get stored deep link data
  static Map<String, String?> getStoredDeepLinkData() {
    // Return stored data or empty map
    return {};
  }
  
  /// Clear stored deep link data
  static Future<void> clearStoredDeepLinkData() async {
    debugPrint('Clearing stored deep link data');
  }
}