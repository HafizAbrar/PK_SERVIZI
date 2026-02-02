import '../../../../core/network/api_client.dart';

class ServiceRequestsRemoteDataSource {
  final ApiClient _apiClient;

  ServiceRequestsRemoteDataSource(this._apiClient);

  Future<List<Map<String, dynamic>>> getMyServiceRequests() async {
    final response = await _apiClient.get('/service-requests/my');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> initiateServiceRequest({
    required String serviceTypeId,
    required Map<String, dynamic> paymentData,
  }) async {
    final response = await _apiClient.post('/service-requests/initiate', data: {
      'serviceTypeId': serviceTypeId,
      'paymentData': paymentData,
    });
    return response.data['data'];
  }

  Future<void> submitQuestionnaire(String requestId, Map<String, dynamic> answers) async {
    await _apiClient.patch('/service-requests/$requestId/questionnaire', data: answers);
  }

  Future<void> uploadDocuments(String requestId, List<String> documentPaths) async {
    await _apiClient.post('/service-requests/$requestId/documents', data: {
      'documents': documentPaths,
    });
  }

  Future<Map<String, dynamic>> createServiceRequest({
    required String serviceTypeId,
    required Map<String, dynamic> formData,
    required List<String> documents,
  }) async {
    final response = await _apiClient.post('/service-requests', data: {
      'serviceTypeId': serviceTypeId,
      'formData': formData,
      'documents': documents,
    });
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getServiceRequestDetails(String requestId) async {
    final response = await _apiClient.get('/service-requests/$requestId');
    return response.data['data'];
  }

  Future<void> submitForProcessing(String requestId) async {
    await _apiClient.post('/service-requests/$requestId/submit');
  }

  Future<List<Map<String, dynamic>>> getStatusHistory(String requestId) async {
    final response = await _apiClient.get('/service-requests/$requestId/status-history');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<void> addNote(String requestId, String note) async {
    await _apiClient.post('/service-requests/$requestId/notes', data: {'note': note});
  }
}