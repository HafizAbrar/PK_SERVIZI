import 'package:dio/dio.dart';

class PaymentService {
  
  PaymentService();
  
  Future<PaymentResult> processPayment({
    required String serviceId,
    required double amount,
    required Map<String, String> billingDetails,
  }) async {
    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      return PaymentResult.success();
    } on DioException catch (e) {
      return PaymentResult.failure(_getApiErrorMessage(e));
    } catch (e) {
      return PaymentResult.failure('Payment failed. Please try again.');
    }
  }
  
  String _getApiErrorMessage(DioException e) {
    if (e.response?.statusCode == 400) {
      return 'Invalid payment information. Please check your details.';
    } else if (e.response?.statusCode == 402) {
      return 'Payment required. Please check your payment method.';
    }
    return 'Network error. Please check your connection and try again.';
  }
}

class PaymentResult {
  final bool isSuccess;
  final String? errorMessage;
  
  PaymentResult._(this.isSuccess, this.errorMessage);
  
  factory PaymentResult.success() => PaymentResult._(true, null);
  factory PaymentResult.failure(String message) => PaymentResult._(false, message);
}