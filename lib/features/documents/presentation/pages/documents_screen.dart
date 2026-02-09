import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  List<dynamic> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      // Load documents from different sources
      final futures = await Future.wait([
        ApiServiceFactory.customer.getDocumentsByRequest('recent'),
        // Add more document sources as needed
      ]);
      
      List<dynamic> allDocuments = [];
      for (var response in futures) {
        if (response.data != null) {
          if (response.data is List) {
            allDocuments.addAll(response.data);
          } else {
            allDocuments.add(response.data);
          }
        }
      }
      
      setState(() {
        documents = allDocuments;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.errorLoadingDocuments ?? 'Error loading documents'}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.documents ?? 'Documents',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            onPressed: () => context.push('/upload-documents'),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : documents.isEmpty
                ? _buildEmptyState()
                : _buildDocumentsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            AppLocalizations.of(context)?.noDocumentsYet ?? 'No documents yet',
            style: TextStyle(
              fontSize: AppTheme.fontSizeXLarge,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ElevatedButton(
            style: AppTheme.primaryButtonStyle,
            onPressed: () => context.push('/upload-documents'),
            child: Text(AppLocalizations.of(context)?.uploadDocuments ?? 'Upload Documents'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(_getDocumentIcon(document['type']), color: Colors.white),
            ),
            title: Text(document['name'] ?? 'Document'),
            subtitle: Text(document['status'] ?? 'Unknown'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(value: 'view', child: Text(AppLocalizations.of(context)?.view ?? 'View')),
                PopupMenuItem(value: 'download', child: Text(AppLocalizations.of(context)?.download ?? 'Download')),
                PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context)?.delete ?? 'Delete')),
              ],
              onSelected: (value) => _handleDocumentAction(value, document),
            ),
            onTap: () => _previewDocument(document),
          ),
        );
      },
    );
  }

  IconData _getDocumentIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  void _handleDocumentAction(String action, dynamic document) async {
    switch (action) {
      case 'view':
        _previewDocument(document);
        break;
      case 'download':
        _downloadDocument(document);
        break;
      case 'delete':
        _deleteDocument(document);
        break;
    }
  }

  void _previewDocument(dynamic document) async {
    try {
      final response = await ApiServiceFactory.customer.previewDocument(document['id']);
      
      if (response.data != null && response.data['previewUrl'] != null) {
        final Uri url = Uri.parse(response.data['previewUrl']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.cannotOpenDocument ?? 'Cannot open document preview')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.previewNotAvailable ?? 'Preview not available')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.errorPreviewingDocument ?? 'Error previewing document'}: $e')),
        );
      }
    }
  }

  void _downloadDocument(dynamic document) async {
    try {
      final response = await ApiServiceFactory.customer.downloadDocument(document['id']);
      
      if (response.data != null && response.data['downloadUrl'] != null) {
        final Uri url = Uri.parse(response.data['downloadUrl']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.downloadStarted ?? 'Download started')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.cannotDownloadDocument ?? 'Cannot download document')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.downloadNotAvailable ?? 'Download not available')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.errorDownloadingDocument ?? 'Error downloading document'}: $e')),
        );
      }
    }
  }

  void _deleteDocument(dynamic document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deleteDocument ?? 'Delete Document'),
        content: Text('${AppLocalizations.of(context)?.confirmDeleteDocument ?? 'Are you sure you want to delete'} "${document['name'] ?? 'this document'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiServiceFactory.customer.deleteDocument(document['id']);
        await _loadDocuments(); // Reload the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.documentDeletedSuccessfully ?? 'Document deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)?.errorDeletingDocument ?? 'Error deleting document'}: $e')),
          );
        }
      }
    }
  }
}
