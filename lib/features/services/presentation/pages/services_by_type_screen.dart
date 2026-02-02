import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/sources/services_remote_data_source.dart';
import '../../../../core/network/api_client.dart';
import 'package:go_router/go_router.dart';

final servicesByTypeProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, serviceTypeId) async {
  final apiClient = ref.read(apiClientProvider);
  final dataSource = ServicesRemoteDataSource(apiClient);
  return dataSource.getServicesByType(serviceTypeId);
});

class ServicesByTypeScreen extends ConsumerWidget {
  final String serviceTypeId;
  
  const ServicesByTypeScreen({super.key, required this.serviceTypeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesByTypeProvider(serviceTypeId));
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Services',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: servicesAsync.when(
          data: (services) => _buildServicesList(context, services),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: AppTheme.spacingMedium),
                Text('Error loading services', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: AppTheme.spacingSmall),
                ElevatedButton(
                  onPressed: () => ref.refresh(servicesByTypeProvider(serviceTypeId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, List<Map<String, dynamic>> services) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'No services available',
              style: TextStyle(fontSize: AppTheme.fontSizeLarge, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            onTap: () => context.push('/services/${service['id']}'),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                    ),
                    child: Icon(
                      Icons.business_center,
                      color: AppTheme.primaryColor,
                      size: AppTheme.iconSizeLarge,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] ?? 'Service',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXSmall),
                        if (service['description'] != null)
                          Text(
                            service['description'],
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppTheme.fontSizeMedium,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (service['price'] != null) ...[
                          const SizedBox(height: AppTheme.spacingXSmall),
                          Text(
                            '€${service['price'].toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: AppTheme.fontSizeMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textSecondary,
                    size: AppTheme.iconSizeSmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}