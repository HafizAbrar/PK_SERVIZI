import '../../../../core/network/api_client.dart';

class ServicesRemoteDataSource {
  final ApiClient _apiClient;

  ServicesRemoteDataSource(this._apiClient);

  Future<List<Map<String, dynamic>>> getServices() async {
    final response = await _apiClient.get('/api/v1/services');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<List<Map<String, dynamic>>> getServicesByType(String serviceTypeId) async {
    final response = await _apiClient.get('/api/v1/services?serviceTypeId=$serviceTypeId');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> getServiceDetails(String serviceId) async {
    final response = await _apiClient.get('/api/v1/services/$serviceId');
    return response.data['data'];
  }

  Future<List<String>> getRequiredDocuments(String serviceId) async {
    final response = await _apiClient.get('/api/v1/services/$serviceId/required-documents');
    return List<String>.from(response.data['data']);
  }
}