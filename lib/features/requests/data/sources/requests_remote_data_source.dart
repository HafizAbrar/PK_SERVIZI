import 'package:dio/dio.dart';
import '../models/service_request.dart';

abstract class RequestsRemoteDataSource {
  Future<List<ServiceRequest>> getMyRequests();
  Future<ServiceRequest> getRequestById(String id);
  Future<ServiceRequest> createRequest(Map<String, dynamic> data);
  Future<ServiceRequest> updateRequest(String id, Map<String, dynamic> data);
  Future<void> cancelRequest(String id);
}

class RequestsRemoteDataSourceImpl implements RequestsRemoteDataSource {
  final Dio _dio;

  RequestsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ServiceRequest>> getMyRequests() async {
    final response = await _dio.get('/api/v1/service-requests/my');
    return (response.data['data'] as List)
        .map((json) => ServiceRequest.fromJson(json))
        .toList();
  }

  @override
  Future<ServiceRequest> getRequestById(String id) async {
    final response = await _dio.get('/api/v1/service-requests/$id');
    return ServiceRequest.fromJson(response.data['data']);
  }

  @override
  Future<ServiceRequest> createRequest(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/service-requests', data: data);
    return ServiceRequest.fromJson(response.data['data']);
  }

  @override
  Future<ServiceRequest> updateRequest(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/v1/service-requests/$id', data: data);
    return ServiceRequest.fromJson(response.data['data']);
  }

  @override
  Future<void> cancelRequest(String id) async {
    await _dio.delete('/api/v1/service-requests/$id');
  }
}