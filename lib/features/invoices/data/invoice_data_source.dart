import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'invoice_model.dart';

final invoiceDataSourceProvider = Provider((ref) => InvoiceDataSource(ref.read(apiClientProvider)));

class InvoiceDataSource {
  final ApiClient apiClient;

  InvoiceDataSource(this.apiClient);

  Future<Map<String, dynamic>> getInvoices({int page = 1, int limit = 10}) async {
    final response = await apiClient.get('/api/v1/invoices?page=$page&limit=$limit');
    final data = response.data;
    return {
      'invoices': (data['data'] as List).map((e) => Invoice.fromJson(e)).toList(),
      'total': data['pagination']['total'],
    };
  }

  Future<Map<String, dynamic>> getPayments({int page = 1, int limit = 100}) async {
    final response = await apiClient.get('/api/v1/payments/my?page=$page&limit=$limit');
    final data = response.data;
    return {
      'payments': (data['data'] as List).map((e) => Payment.fromJson(e)).toList(),
    };
  }

  Future<Invoice> getInvoiceById(String id) async {
    final response = await apiClient.get('/api/v1/invoices/$id');
    return Invoice.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> downloadInvoice(String id) async {
    final response = await apiClient.get('/api/v1/invoices/$id/download');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> downloadPaymentReceipt(String paymentId) async {
    final response = await apiClient.get('/api/v1/payments/$paymentId/receipt');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> generatePaymentInvoice(String paymentId) async {
    final response = await apiClient.get('/api/v1/payments/$paymentId/invoice');
    return response.data['data'];
  }
}
