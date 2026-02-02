import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';

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
    final requestAsync = ref.watch(serviceRequestDetailNewProvider(requestId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: requestAsync.when(
        data: (request) => _buildContent(context, request),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
        error: (error, stack) => _buildError(context, ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> request) {
    final service = request['service'] as Map<String, dynamic>;
    
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, service['name'] ?? 'Service Request'),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildStatusCard(request),
              _buildServiceInfo(service),
              _buildProgressTimeline(request),
              if (request['documents'] != null) _buildDocuments(request['documents']),
              _buildActionButtons(context, request),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF186ADC),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF186ADC), Color(0xFF1E40AF)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> request) {
    final status = request['status'] ?? 'pending';
    
    return Container(
      margin: const EdgeInsets.all(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REF: #${request['id']?.toString().substring(0, 8).toUpperCase() ?? 'N/A'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(status).withValues(alpha: 0.3)),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Created', _formatDate(request['createdAt'])),
          if (request['formCompletedAt'] != null)
            _buildInfoRow('Form Completed', _formatDate(request['formCompletedAt'])),
          if (request['documentsUploadedAt'] != null)
            _buildInfoRow('Documents Uploaded', _formatDate(request['documentsUploadedAt'])),
          if (request['completedAt'] != null)
            _buildInfoRow('Completed', _formatDate(request['completedAt'])),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Service', service['name'] ?? 'N/A'),
          _buildInfoRow('Code', service['code'] ?? 'N/A'),
          _buildInfoRow('Category', service['category'] ?? 'N/A'),
          _buildInfoRow('Price', '€${service['basePrice'] ?? '0.00'}'),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline(Map<String, dynamic> request) {
    final statusHistory = request['statusHistory'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 16),
          ...statusHistory.map((history) => _buildTimelineItem(history)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF186ADC),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getStatusText(history['fromStatus'])} → ${_getStatusText(history['toStatus'])}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111418)),
                ),
                if (history['notes'] != null)
                  Text(
                    history['notes'],
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                Text(
                  _formatDate(history['createdAt']),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments(List<dynamic> documents) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 16),
          documents.isEmpty
              ? const Text('No documents uploaded yet', style: TextStyle(color: Color(0xFF6B7280)))
              : Column(children: documents.map((doc) => _buildDocumentItem(doc)).toList()),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, size: 20, color: Color(0xFF186ADC)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              document['name'] ?? 'Document',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> request) {
    final status = request['status'] ?? 'pending';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (status == 'payment_pending')
                        Consumer(
              builder: (context, ref, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _initiatePayment(context, request, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Complete Payment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          if (status == 'awaiting_form')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/service-request-form?serviceId=${request['serviceId']}&requestId=${request['id']}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Fill the Form',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          if (status == 'awaiting_documents')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/document-upload?serviceId=${request['serviceId']}&requestId=${request['id']}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Upload Documents',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          if (status == 'ready_to_submit')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/request-submission/${request['id']}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF186ADC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _initiatePayment(BuildContext context, Map<String, dynamic> request, WidgetRef ref) async {
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
          const SnackBar(content: Text('Failed to initiate payment')),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF111418), fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'awaiting_documents':
        return const Color(0xFFEF4444);
      case 'awaiting_form':
        return const Color(0xFFF59E0B);
      case 'processing':
        return const Color(0xFF186ADC);
      case 'completed':
        return const Color(0xFF10B981);
      case 'payment_pending':
        return const Color(0xFF10B981);
      case 'ready_to_submit':
        return const Color(0xFF186ADC);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'awaiting_documents':
        return 'Awaiting Documents';
      case 'awaiting_form':
        return 'Awaiting Form';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'payment_pending':
        return 'Payment Pending';
      case 'ready_to_submit':
        return 'Ready to Submit';
      default:
        return 'Pending';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          const Text('Failed to load request details', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(serviceRequestDetailNewProvider(requestId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}