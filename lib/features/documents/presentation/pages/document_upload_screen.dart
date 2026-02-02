import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/network/api_client.dart';

final requiredDocumentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, serviceId) async {
  final apiClient = ref.read(apiClientProvider);
  try {
    final response = await apiClient.get('/api/v1/services/$serviceId/required-documents');
    final data = response.data['data'] ?? response.data ?? [];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    // Fallback with sample documents if API returns empty or invalid data
    return [
      {'id': 'identity', 'name': 'Identity Document', 'description': 'Valid ID card or passport', 'required': true},
      {'id': 'tax_code', 'name': 'Tax Code', 'description': 'Codice fiscale document', 'required': true},
      {'id': 'residence', 'name': 'Residence Certificate', 'description': 'Certificate of residence', 'required': false},
    ];
  } catch (e) {
    // Return sample documents on error
    return [
      {'id': 'identity', 'name': 'Identity Document', 'description': 'Valid ID card or passport', 'required': true},
      {'id': 'tax_code', 'name': 'Tax Code', 'description': 'Codice fiscale document', 'required': true},
      {'id': 'residence', 'name': 'Residence Certificate', 'description': 'Certificate of residence', 'required': false},
    ];
  }
});

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String requestId;
  
  const DocumentUploadScreen({
    super.key,
    required this.serviceId,
    required this.requestId,
  });

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final Map<String, File?> _selectedFiles = {};
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(requiredDocumentsProvider(widget.serviceId));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: documentsAsync.when(
              data: (documents) => _buildDocumentsList(documents),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
              error: (_, __) => _buildError(),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111418)),
          ),
          const Expanded(
            child: Text(
              'Upload Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(List<Map<String, dynamic>> documents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Documents',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please upload all required documents to proceed with your service request.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          ...documents.map((doc) => _buildDocumentCard(doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final docId = document['id'] ?? document['name'] ?? 'unknown';
    final selectedFile = _selectedFiles[docId];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                document['required'] == true ? Icons.assignment : Icons.assignment_outlined,
                color: document['required'] == true ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document['name'] ?? 'Document',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
                    ),
                    if (document['description'] != null)
                      Text(
                        document['description'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: document['required'] == true ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  document['required'] == true ? 'Required' : 'Optional',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: document['required'] == true ? const Color(0xFFDC2626) : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showImageSourceDialog(docId),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedFile != null ? const Color(0xFF186ADC) : const Color(0xFFE2E8F0),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
                color: selectedFile != null ? const Color(0xFF186ADC).withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
              ),
              child: Column(
                children: [
                  Icon(
                    selectedFile != null ? Icons.check_circle : Icons.upload_file,
                    size: 32,
                    color: selectedFile != null ? const Color(0xFF186ADC) : const Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedFile != null ? selectedFile.path.split('/').last : 'Click to upload',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selectedFile != null ? const Color(0xFF186ADC) : const Color(0xFF6B7280),
                    ),
                  ),
                  if (selectedFile == null)
                    const Text(
                      'Camera or Gallery (JPG, PNG)',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isUploading ? null : _uploadDocuments,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF186ADC),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isUploading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : const Text(
                  'Upload Documents',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          const Text('Failed to load required documents', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(requiredDocumentsProvider(widget.serviceId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog(String docId) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF186ADC)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(docId, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF186ADC)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(docId, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(String docId, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedFiles[docId] = File(image.path);
      });
    }
  }

  Future<void> _uploadDocuments() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one document')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      
      // Upload all documents
      for (var entry in _selectedFiles.entries) {
        if (entry.value != null) {
          String fieldName = entry.key;
          if (entry.key == 'identity') fieldName = 'identityDocument';
          if (entry.key == 'tax_code') fieldName = 'fiscalCode';
          
          final formData = FormData.fromMap({
            fieldName: await MultipartFile.fromFile(
              entry.value!.path,
              filename: entry.value!.path.split('/').last,
            ),
          });

          await apiClient.post(
            '/api/v1/service-requests/${widget.requestId}/documents',
            data: formData,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documents uploaded successfully')),
        );
        // Navigate to submission screen with requestId
        context.push('/request-submission?requestId=${widget.requestId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading documents: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}