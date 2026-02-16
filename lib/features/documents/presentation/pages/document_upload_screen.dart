import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/translated_text.dart';

final requiredDocumentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, serviceId) async {
  final apiClient = ref.read(apiClientProvider);
  try {
    final response = await apiClient.get('/api/v1/services/$serviceId/required-documents');
    final data = response.data['data'] ?? response.data ?? [];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [
      {'id': 'identity', 'name': 'Identity Document', 'description': 'Valid ID card or passport', 'required': true},
      {'id': 'tax_code', 'name': 'Tax Code', 'description': 'Codice fiscale document', 'required': true},
      {'id': 'residence', 'name': 'Residence Certificate', 'description': 'Certificate of residence', 'required': false},
    ];
  } catch (e) {
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
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: documentsAsync.when(
              data: (documents) => _buildDocumentsList(documents),
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
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
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                padding: EdgeInsets.zero,
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.upload_file, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)?.uploadDocuments ?? 'Upload Documents',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(List<Map<String, dynamic>> documents) {
    if (documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Documents Required',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Great! No documents are required for this service. You can proceed to submit your request.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.requiredDocuments ?? 'Required Documents',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.uploadDocumentsDescription ?? 'Please upload all required documents to proceed.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ...documents.map((doc) => _buildDocumentCard(doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final docId = document['id'] ?? document['name'] ?? 'unknown';
    final selectedFile = _selectedFiles[docId];
    final isRequired = document['required'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRequired 
                      ? AppTheme.errorColor.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isRequired ? Icons.assignment : Icons.assignment_outlined,
                  color: isRequired ? AppTheme.errorColor : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      document['name'] ?? 'Document',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    if (document['description'] != null)
                      TranslatedText(
                        document['description'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isRequired 
                      ? AppTheme.errorColor.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isRequired ? (AppLocalizations.of(context)?.required ?? 'Required') : (AppLocalizations.of(context)?.optional ?? 'Optional'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isRequired ? AppTheme.errorColor : Colors.grey[600],
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedFile != null ? AppTheme.primaryColor : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: selectedFile != null 
                    ? AppTheme.primaryColor.withValues(alpha: 0.05) 
                    : AppTheme.backgroundLight,
              ),
              child: Column(
                children: [
                  Icon(
                    selectedFile != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                    size: 40,
                    color: selectedFile != null ? AppTheme.primaryColor : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedFile != null 
                        ? selectedFile.path.split('/').last 
                        : (AppLocalizations.of(context)?.clickToUpload ?? 'Click to upload'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedFile != null ? AppTheme.primaryColor : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (selectedFile == null)
                    const SizedBox(height: 4),
                  if (selectedFile == null)
                    Text(
                      AppLocalizations.of(context)?.cameraOrGallery ?? 'Camera or Gallery (JPG, PNG)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
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
    final documentsAsync = ref.watch(requiredDocumentsProvider(widget.serviceId));
    final hasDocuments = documentsAsync.maybeWhen(
      data: (docs) => docs.isNotEmpty,
      orElse: () => true,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isUploading ? null : (hasDocuments ? _uploadDocuments : _continueToSubmit),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isUploading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  hasDocuments 
                      ? (AppLocalizations.of(context)?.uploadDocuments ?? 'Upload Documents')
                      : 'Continue to Submit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)?.failedToLoadDocuments ?? 'Failed to load required documents',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.refresh(requiredDocumentsProvider(widget.serviceId)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              AppLocalizations.of(context)?.retry ?? 'Retry',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog(String docId) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                ),
                title: Text(
                  AppLocalizations.of(context)?.camera ?? 'Camera',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(docId, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
                ),
                title: Text(
                  AppLocalizations.of(context)?.gallery ?? 'Gallery',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(docId, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
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
        SnackBar(
          content: Text(AppLocalizations.of(context)?.selectAtLeastOneDocument ?? 'Please select at least one document'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      
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
          SnackBar(
            content: Text(AppLocalizations.of(context)?.documentsUploadedSuccessfully ?? 'Documents uploaded successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.push('/request-submission?requestId=${widget.requestId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)?.errorUploadingDocuments ?? 'Error uploading documents'}: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _continueToSubmit() {
    context.push('/request-submission?requestId=${widget.requestId}');
  }
}
