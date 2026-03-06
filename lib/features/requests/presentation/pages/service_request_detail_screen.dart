import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/translated_text.dart';

final serviceRequestDetailNewProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, requestId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/service-requests/$requestId');
  return response.data['data'] as Map<String, dynamic>;
});

class ServiceRequestDetailScreenNew extends ConsumerWidget {
  final String requestId;
  
  const ServiceRequestDetailScreenNew({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final requestAsync = ref.watch(serviceRequestDetailNewProvider(requestId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: requestAsync.when(
        data: (request) => _buildContent(context, ref, request, l10n),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (error, stack) => _buildError(context, ref, l10n),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic> request, AppLocalizations l10n) {
    final service = request['service'] as Map<String, dynamic>;
    
    return Column(
      children: [
        _buildHeader(context, service['name'] ?? l10n.serviceRequest, l10n),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildStatusCard(request, l10n),
                _buildServiceInfo(service, l10n),
                _buildProgressTimeline(request, l10n),
                _buildActionButtons(context, request, ref, l10n),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String title, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 75),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/logos/outer logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TranslatedText(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> request, AppLocalizations l10n) {
    final status = request['status'] ?? 'pending';
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REF: #${request['id']?.toString().substring(0, 8).toUpperCase() ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(status).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(status, l10n),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(l10n.created, _formatDate(request['createdAt']), l10n),
          if (request['formCompletedAt'] != null)
            _buildInfoRow(l10n.formCompleted, _formatDate(request['formCompletedAt']), l10n),
          if (request['documentsUploadedAt'] != null)
            _buildInfoRow(l10n.documentsUploaded, _formatDate(request['documentsUploadedAt']), l10n),
          if (request['completedAt'] != null)
            _buildInfoRow(l10n.completed, _formatDate(request['completedAt']), l10n),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(Map<String, dynamic> service, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            l10n.serviceInformation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(l10n.service, service['name'] ?? 'N/A', l10n, translate: true),
          _buildInfoRow(l10n.price, '€${service['basePrice'] ?? '0.00'}', l10n),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline(Map<String, dynamic> request, AppLocalizations l10n) {
    final status = request['status'] ?? 'pending';
    final service = request['service'] as Map<String, dynamic>;
    final basePrice = service['basePrice'];
    
    debugPrint('Service basePrice: $basePrice (type: ${basePrice.runtimeType})');
    
    final isFreeService = (basePrice is int && basePrice == 0) || 
                          (basePrice is double && basePrice == 0.0) || 
                          (basePrice is String && (basePrice == '0' || basePrice == '0.0' || double.tryParse(basePrice) == 0));
    
    debugPrint('Is free service: $isFreeService');
    
    if (isFreeService) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Text(
              l10n.progressTimeline,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTimelineStep(
              1,
              '${l10n.form} & ${l10n.documents}',
              _getStepStatus(status, 'form'),
              l10n.formAndDocumentsCompleted,
              request['formCompletedAt'],
              l10n,
            ),
            _buildTimelineStep(
              2,
              l10n.submit,
              _getStepStatus(status, 'submit'),
              l10n.requestSubmittedSuccessfully,
              request['completedAt'],
              l10n,
              isLast: true,
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            l10n.progressTimeline,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineStep(
            1,
            l10n.payment,
            _getStepStatus(status, 'payment'),
            l10n.paymentCompleted,
            request['createdAt'],
            l10n,
          ),
          _buildTimelineStep(
            2,
            '${l10n.form} & ${l10n.documents}',
            _getStepStatus(status, 'form'),
            l10n.formAndDocumentsCompleted,
            request['formCompletedAt'],
            l10n,
          ),
          _buildTimelineStep(
            3,
            l10n.submit,
            _getStepStatus(status, 'submit'),
            l10n.requestSubmittedSuccessfully,
            request['completedAt'],
            l10n,
            isLast: true,
          ),
        ],
      ),
    );
  }

  String _getStepStatus(String requestStatus, String step) {
    switch (step) {
      case 'payment':
        return (requestStatus == 'payment_pending') ? 'pending' : 'completed';
      case 'form':
        if (requestStatus == 'payment_pending') return 'pending';
        if (requestStatus == 'awaiting_form') return 'current';
        if (requestStatus == 'awaiting_documents' || requestStatus == 'ready_to_submit' || requestStatus == 'submitted' || requestStatus == 'processing' || requestStatus == 'completed') return 'completed';
        return 'pending';
      case 'submit':
        if (requestStatus == 'submitted' || requestStatus == 'processing' || requestStatus == 'completed') return 'completed';
        if (requestStatus == 'ready_to_submit') return 'current';
        return 'pending';
      default:
        return 'pending';
    }
  }

  Widget _buildTimelineStep(
    int stepNumber,
    String title,
    String status,
    String description,
    String? completedAt,
    AppLocalizations l10n,
    {bool isLast = false}
  ) {
    final isCompleted = status == 'completed';
    final isCurrent = status == 'current';
    final isPending = status == 'pending';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : isCurrent
                            ? AppTheme.accentColor
                            : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            stepNumber.toString(),
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: isCompleted ? const Color(0xFF10B981) : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted || isCurrent
                          ? AppTheme.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompleted
                        ? description
                        : isCurrent
                            ? l10n.inProgress
                            : l10n.pending,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isCompleted && completedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(completedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (!isLast) const SizedBox(height: 0),
      ],
    );
  }

  Widget _buildDocuments(List<dynamic> documents, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            l10n.documents,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          documents.isEmpty
              ? Text(
                  l10n.noDocumentsUploaded,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                )
              : Column(
                  children: documents.map((doc) => _buildDocumentItem(doc, l10n)).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> document, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              size: 24,
              color: Colors.red[500],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              document['name'] ?? l10n.document,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> request, WidgetRef ref, AppLocalizations l10n) {
    final status = request['status'] ?? 'pending';
    final service = request['service'] as Map<String, dynamic>;
    final price = service['basePrice'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (status == 'payment_pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _initiatePayment(context, request, ref, l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.completePayment,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          if (status == 'awaiting_form')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/service-request-form?serviceId=${request['serviceId']}&requestId=${request['id']}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.fillTheForm,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          if (status == 'awaiting_documents' || status == 'ready_to_submit')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitRequest(context, request, ref, l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.submitRequest,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          if (status != 'submitted' && status != 'processing' && status != 'completed') ...[
            if (status == 'payment_pending' || status == 'awaiting_form' || status == 'awaiting_documents' || status == 'ready_to_submit')
              const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (price != 0 && status != 'payment_pending') {
                    _cancelRequest(context, request, ref, l10n);
                  } else {
                    _deleteRequest(context, request, ref, l10n);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  price != 0 && status != 'payment_pending' ? 'Cancel Request' : 'Delete Request',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _cancelRequest(BuildContext context, Map<String, dynamic> request, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<String?>(
      context: context,
      builder: (context) {
        final reasonController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cancel Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to cancel this request? Refund will be processed immediately.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason for cancellation *',
                    hintText: 'Please provide a reason...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(l10n.cancel, style: const TextStyle(fontSize: 14)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(reasonController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel Request', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed.isNotEmpty && context.mounted) {
      try {
        final apiClient = ref.read(apiClientProvider);
        debugPrint('Cancelling request with reason: $confirmed');
        
        final response = await apiClient.post(
          '/api/v1/service-requests/${request['id']}/refund',
          data: {'reason': confirmed},
        );
        
        debugPrint('Cancel response: ${response.data}');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request cancelled and refund processed successfully'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/home');
        }
      } catch (e) {
        debugPrint('Cancel error details: $e');
        String errorMessage = 'Error cancelling request';
        if (e.toString().contains('DioException')) {
          try {
            final dioError = e as dynamic;
            if (dioError.response?.data != null) {
              errorMessage = dioError.response.data['message'] ?? dioError.response.data['error'] ?? errorMessage;
            }
          } catch (_) {}
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteRequest(BuildContext context, Map<String, dynamic> request, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.delete('/api/v1/service-requests/${request['id']}');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request deleted successfully'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _submitRequest(BuildContext context, Map<String, dynamic> request, WidgetRef ref, AppLocalizations l10n) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post('/api/v1/service-requests/${request['id']}/submit');
      
      ref.invalidate(serviceRequestDetailNewProvider(requestId));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.requestSubmittedSuccessfully),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Submit error: $e');
      if (context.mounted) {
        String errorMessage = l10n.error;
        if (e.toString().contains('400')) {
          errorMessage = 'Please complete all required steps before submitting';
        } else if (e.toString().contains('DioException')) {
          try {
            final dioError = e as dynamic;
            if (dioError.response?.data != null) {
              errorMessage = dioError.response.data['message'] ?? dioError.response.data['error'] ?? errorMessage;
            }
          } catch (_) {}
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _initiatePayment(BuildContext context, Map<String, dynamic> request, WidgetRef ref, AppLocalizations l10n) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/api/v1/service-requests/initiate', data: {
        'serviceId': request['serviceId'],
      });
      
      if (context.mounted) {
        if (response.data['success'] == true) {
          final paymentUrl = response.data['data']['paymentUrl'] as String;
          final serviceRequestId = response.data['data']['serviceRequestId'] as String;
          context.push('/payment-checkout?url=${Uri.encodeComponent(paymentUrl)}&serviceRequestId=$serviceRequestId&serviceId=${request['serviceId']}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToInitiatePayment),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, AppLocalizations l10n, {bool translate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: translate
                ? TranslatedText(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey[600]!;
      case 'awaiting_documents':
        return const Color(0xFFEF4444);
      case 'awaiting_form':
        return const Color(0xFFF59E0B);
      case 'processing':
      case 'submitted':
        return AppTheme.accentColor;
      case 'completed':
        return const Color(0xFF10B981);
      case 'payment_pending':
        return const Color(0xFF10B981);
      case 'ready_to_submit':
        return AppTheme.accentColor;
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'DRAFT';
      case 'awaiting_documents':
        return l10n.awaitingDocuments;
      case 'awaiting_form':
        return l10n.awaitingForm;
      case 'processing':
        return l10n.processing;
      case 'submitted':
        return 'SUBMITTED';
      case 'completed':
        return l10n.completed;
      case 'payment_pending':
        return l10n.paymentPending;
      case 'ready_to_submit':
        return l10n.readyToSubmit;
      case 'rejected':
        return l10n.rejected;
      default:
        return status.toUpperCase().replaceAll('_', ' ');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildError(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.failedToLoadRequestDetails,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.refresh(serviceRequestDetailNewProvider(requestId)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.retry, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
