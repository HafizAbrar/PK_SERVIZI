import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class PaymentEmailHandler {
  /// Handle requestId from email after successful payment
  /// Call this method when user clicks on email link with requestId
  static void handlePaymentSuccessEmail(BuildContext context, String requestId, {String? serviceId}) {
    // Navigate to payment success screen with requestId
    final queryParams = <String, String>{'requestId': requestId};
    if (serviceId != null) {
      queryParams['serviceId'] = serviceId;
    }
    
    context.go('/payment-success?${_buildQueryString(queryParams)}');
  }
  
  /// Handle direct navigation to service request from email
  static void handleServiceRequestEmail(BuildContext context, String requestId) {
    context.go('/service-requests/$requestId');
  }
  
  /// Build query string from parameters
  static String _buildQueryString(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  
  /// Show success dialog with requestId information
  static void showPaymentSuccessDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('Your payment has been processed successfully.'),
            const SizedBox(height: 8),
            Text('Request ID: $requestId', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/service-requests/$requestId');
            },
            child: const Text('View Request'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }
}