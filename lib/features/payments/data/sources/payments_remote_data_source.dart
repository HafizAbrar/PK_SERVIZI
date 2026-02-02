import '../models/payment.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_routes.dart';

class PaymentsRemoteDataSource {
  final ApiClient _apiClient;

  PaymentsRemoteDataSource(this._apiClient);

  Future<List<Payment>> getMyPayments() async {
    final response = await _apiClient.get(ApiEndpoints.myPayments);
    return (response.data['data'] as List)
        .map((json) => Payment.fromJson(json))
        .toList();
  }

  Future<String> downloadPaymentReceipt(String paymentId) async {
    final response = await _apiClient.get(
      ApiEndpoints.paymentReceipt(paymentId),
    );
    return response.data;
  }

  Future<String> generatePaymentInvoice(String paymentId) async {
    final response = await _apiClient.get(
      ApiEndpoints.paymentInvoice(paymentId),
    );
    return response.data;
  }

  Future<void> resendPaymentReceipt(String paymentId) async {
    await _apiClient.post(ApiEndpoints.resendPaymentReceipt(paymentId));
  }

  // Admin only
  Future<List<Payment>> getAllPayments() async {
    final response = await _apiClient.get('/payments');
    return (response.data['data'] as List)
        .map((json) => Payment.fromJson(json))
        .toList();
  }

  Future<void> processRefund(String paymentId) async {
    await _apiClient.post('/payments/$paymentId/refund');
  }
}