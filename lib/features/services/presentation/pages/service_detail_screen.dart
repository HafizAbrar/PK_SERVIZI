import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/service.dart';

final serviceDetailProvider = FutureProvider.family<Service, String>((ref, serviceId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/services/$serviceId');
  return Service.fromJson(response.data['data']);
});

final serviceFaqsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, serviceId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/faqs/service/$serviceId');
  return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
});

class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;
  
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceDetailProvider(serviceId));
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: serviceAsync.when(
        data: (service) => _buildContent(context, service, ref),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
        error: (_, __) => _buildError(context, ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Service service, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, service),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildServiceHeader(service),
              _buildRequiredDocuments(service),
              _buildFormSections(service),
              _buildFAQs(ref),
              _buildActionButton(context, service, ref),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, Service service) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF186ADC),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag, color: Colors.white, size: 40),
            const SizedBox(height: 4),
            Text(
              service.name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
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

  Widget _buildServiceHeader(Service service) {
    return Container(
      margin: const EdgeInsets.all(24),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF186ADC).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, size: 24, color: Color(0xFF186ADC)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Service Details',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Name', service.name),
          _buildDetailRow('Code', service.code),
          _buildDetailRow('Description', service.description),
          _buildDetailRow('Category', service.category),
          _buildDetailRow('Price', '€${service.basePrice}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF637288)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111418)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocuments(Service service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
            'Required Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 16),
          ...service.requiredDocuments.map((doc) => _buildDocumentTile(doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(RequiredDocument doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            doc.required ? Icons.check_circle : Icons.info_outline,
            size: 20,
            color: doc.required ? const Color(0xFF10B981) : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
                ),
                Text(
                  'Category: ${doc.category}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF637288)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: doc.required ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              doc.required ? 'Required' : 'Optional',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: doc.required ? const Color(0xFF166534) : const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSections(Service service) {
    if (service.formSchema == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(24),
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
            'Required Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 16),
          ...service.formSchema!.sections.map((section) => _buildSectionTile(section)),
        ],
      ),
    );
  }

  Widget _buildSectionTile(FormSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        tileColor: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: const Icon(Icons.folder_outlined, color: Color(0xFF186ADC)),
        title: Text(
          section.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
        ),
        subtitle: Text(
          '${section.fields.length} fields required',
          style: const TextStyle(fontSize: 12, color: Color(0xFF637288)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
      ),
    );
  }

  Widget _buildFAQs(WidgetRef ref) {
    final faqsAsync = ref.watch(serviceFaqsProvider(serviceId));

    return Container(
      margin: const EdgeInsets.all(24),
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
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 16),
          faqsAsync.when(
            data: (faqs) => faqs.isEmpty 
                ? const Text('No FAQs available for this service.', style: TextStyle(color: Color(0xFF637288)))
                : Column(children: faqs.map((faq) => _buildFAQItem(faq['question'] ?? '', faq['answer'] ?? '')).toList()),
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
            error: (_, __) => const Text('Failed to load FAQs', style: TextStyle(color: Color(0xFF637288))),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 14, color: Color(0xFF637288)),
          ),
        ],
      ),
    );
  }



  Widget _buildActionButton(BuildContext context, Service service, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () => _initiateServiceRequest(context, service.id, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF186ADC),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Start Service Request - €${service.basePrice}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _initiateServiceRequest(BuildContext context, String serviceId, WidgetRef ref) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/api/v1/service-requests/initiate', data: {
        'serviceId': serviceId,
      });
      
      if (context.mounted) {
        if (response.data['success'] == true) {
          final paymentUrl = response.data['data']['paymentUrl'] as String;
          context.push('/payment-checkout?url=${Uri.encodeComponent(paymentUrl)}&serviceId=$serviceId');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initiate service request')),
        );
      }
    }
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          const Text('Failed to load service details', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(serviceDetailProvider(serviceId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}