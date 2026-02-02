import 'package:dio/dio.dart';
import '../models/document.dart';

abstract class DocumentsRemoteDataSource {
  Future<List<Document>> getDocuments();
  Future<List<Document>> getDocumentsByRequest(String requestId);
  Future<Document> uploadDocument(String requestId, String documentType, String filePath);
  Future<void> deleteDocument(String id);
  Future<String> downloadDocument(String id);
}

class DocumentsRemoteDataSourceImpl implements DocumentsRemoteDataSource {
  final Dio _dio;

  DocumentsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Document>> getDocuments() async {
    final response = await _dio.get('/api/v1/documents');
    return (response.data['data'] as List)
        .map((json) => Document.fromJson(json))
        .toList();
  }

  @override
  Future<List<Document>> getDocumentsByRequest(String requestId) async {
    final response = await _dio.get('/api/v1/documents/request/$requestId');
    return (response.data['data'] as List)
        .map((json) => Document.fromJson(json))
        .toList();
  }

  @override
  Future<Document> uploadDocument(String requestId, String documentType, String filePath) async {
    final formData = FormData.fromMap({
      'requestId': requestId,
      'documentType': documentType,
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post('/api/v1/documents/upload', data: formData);
    return Document.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _dio.delete('/api/v1/documents/$id');
  }

  @override
  Future<String> downloadDocument(String id) async {
    final response = await _dio.get('/api/v1/documents/$id/download');
    return response.data['data']['url'];
  }
}