import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'package:go_router/go_router.dart';

final serviceTypesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/service-types');
  return List<Map<String, dynamic>>.from(response.data['data']);
});

final selectedServiceTypeProvider = StateProvider<String?>((ref) => null);

final servicesByTypeProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, serviceTypeId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/services?serviceTypeId=$serviceTypeId');
  return List<Map<String, dynamic>>.from(response.data['data']);
});

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceTypesAsync = ref.watch(serviceTypesProvider);
    final selectedServiceType = ref.watch(selectedServiceTypeProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryTabs(serviceTypesAsync),
          Expanded(
            child: _buildServicesList(selectedServiceType),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Our Services',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111418),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => context.go('/notifications'),
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      color: Colors.white,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Search services...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
            prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(AsyncValue<List<Map<String, dynamic>>> serviceTypesAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: serviceTypesAsync.when(
        data: (serviceTypes) {
          // Auto-select first service type if none selected
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (serviceTypes.isNotEmpty && ref.read(selectedServiceTypeProvider) == null) {
              ref.read(selectedServiceTypeProvider.notifier).state = serviceTypes.first['id'];
            }
          });
          
          return SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: serviceTypes.map((type) => _buildCategoryTab(
                type['name'] ?? 'Type',
                type['id'],
                ref.watch(selectedServiceTypeProvider) == type['id'],
              )).toList(),
            ),
          );
        },
        loading: () => const SizedBox(height: 40),
        error: (_, __) => const SizedBox(height: 40),
      ),
    );
  }

  Widget _buildCategoryTab(String label, String serviceTypeId, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => ref.read(selectedServiceTypeProvider.notifier).state = serviceTypeId,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF186ADC) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesList(String? selectedServiceType) {
    if (selectedServiceType == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC)));
    }
    
    final servicesAsync = ref.watch(servicesByTypeProvider(selectedServiceType));
    
    return servicesAsync.when(
      data: (services) {
        final filteredServices = services.where((service) {
          if (_searchQuery.isEmpty) return true;
          return (service['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredServices.length,
          itemBuilder: (context, index) => _buildServiceCard(filteredServices[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
      error: (_, __) => _buildErrorState(() => ref.refresh(servicesByTypeProvider(selectedServiceType))),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'] ?? 'Service',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111418),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['price'] != null ? '€${service['price']}' : 'Free consultation',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF186ADC),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              service['description'] ?? 'Professional service with expert guidance',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.push('/services/${service['id']}'),
                  child: const Text(
                    'View Detail',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF186ADC)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _initiateServiceRequest(context, service['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF186ADC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Get Service',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try again',
            style: TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF186ADC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateServiceRequest(BuildContext context, String serviceId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/api/v1/service-requests/initiate', data: {
        'serviceId': serviceId,
      });
      
      if (context.mounted) {
        if (response.data['success'] == true) {
          final paymentUrl = response.data['data']['paymentUrl'] as String;
          final serviceRequestId = response.data['data']['serviceRequestId'] as String;
          context.push('/payment-checkout?url=${Uri.encodeComponent(paymentUrl)}&serviceRequestId=$serviceRequestId&serviceId=$serviceId');
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
}