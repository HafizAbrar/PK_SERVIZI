import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/translation_service.dart';

final serviceTypesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/service-types');
  final list = List<Map<String, dynamic>>.from(response.data['data']);
  list.sort((a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase()));
  return list;
});

final selectedServiceTypeProvider = StateProvider<String?>((ref) => null);

final servicesByTypeProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, serviceTypeId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/services?serviceTypeId=$serviceTypeId');
  return List<Map<String, dynamic>>.from(response.data['data']);
});

class ServicesScreen extends ConsumerStatefulWidget {
  final String? serviceTypeId;
  
  const ServicesScreen({super.key, this.serviceTypeId});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.serviceTypeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedServiceTypeProvider.notifier).state = widget.serviceTypeId;
      });
    }
  }

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
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 36),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.services,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      transform: Matrix4.translationValues(0, -24, 0),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: l10n.searchDocumentsOrServices,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 24),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(AsyncValue<List<Map<String, dynamic>>> serviceTypesAsync) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: serviceTypesAsync.when(
        data: (serviceTypes) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (serviceTypes.isNotEmpty && ref.read(selectedServiceTypeProvider) == null) {
              ref.read(selectedServiceTypeProvider.notifier).state = serviceTypes.first['id'];
            }
          });
          
          // Sort by translated name
          final locale = Localizations.localeOf(context).languageCode;
          final sortedTypes = List<Map<String, dynamic>>.from(serviceTypes);
          sortedTypes.sort((a, b) {
            final nameA = TranslationService.getCached(a['name'] ?? '', locale) ?? a['name'] ?? '';
            final nameB = TranslationService.getCached(b['name'] ?? '', locale) ?? b['name'] ?? '';
            return nameA.toLowerCase().compareTo(nameB.toLowerCase());
          });
          
          return SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: sortedTypes.map((type) => _buildCategoryTab(
                type['name'] ?? 'Type',
                type['id'],
                ref.watch(selectedServiceTypeProvider) == type['id'],
              )).toList(),
            ),
          );
        },
        loading: () => const SizedBox(height: 50),
        error: (_, __) => const SizedBox(height: 50),
      ),
    );
  }

  Widget _buildCategoryTab(String label, String serviceTypeId, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => ref.read(selectedServiceTypeProvider.notifier).state = serviceTypeId,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ] : null,
          ),
          child: TranslatedText(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesList(String? selectedServiceType) {
    if (selectedServiceType == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }
    
    final servicesAsync = ref.watch(servicesByTypeProvider(selectedServiceType));
    
    return servicesAsync.when(
      data: (services) {
        final filteredServices = services.where((service) {
          if (_searchQuery.isEmpty) return true;
          return (service['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredServices.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredServices.length,
          itemBuilder: (context, index) => _buildServiceCard(filteredServices[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      error: (_, __) => _buildErrorState(() => ref.refresh(servicesByTypeProvider(selectedServiceType))),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.business, size: 28, color: AppTheme.accentColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(
                        service['name'] ?? 'Service',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['price'] != null ? '€${service['price']}' : '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TranslatedText(
              service['description'] ?? 'Professional service with expert guidance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: () => context.push('/services/${service['id']}'),
                    child: Text(
                      l10n.viewDetails,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => _initiateServiceRequest(context, service['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.startService.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noServiceRequests,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pleaseTryAgain,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VoidCallback onRetry) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.error,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pleaseTryAgain,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.retry.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateServiceRequest(BuildContext context, String serviceId) async {
    final l10n = AppLocalizations.of(context)!;
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
          SnackBar(
            content: Text(l10n.failedToInitiateServiceRequest),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}
