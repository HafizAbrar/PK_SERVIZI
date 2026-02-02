import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'main_navigation_screen.dart';

final homeDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final responses = await Future.wait([
      ApiServiceFactory.customer.getMyServiceRequests(),
      ApiServiceFactory.customer.getMySubscription(),
      ApiServiceFactory.customer.getMyNotifications(),
      ApiServiceFactory.public.getSubscriptionPlans(),
    ]);
    return {
      'requests': responses[0].data['data'] ?? [],
      'subscription': responses[1].data['data'],
      'notifications': responses[2].data['data'] ?? [],
      'plans': responses[3].data['data'] ?? [],
    };
  } catch (e) {
    return {
      'requests': [],
      'subscription': null,
      'notifications': [],
      'plans': [],
    };
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Column(
        children: [
          _buildTopNavigation(),
          Expanded(
            child: homeDataAsync.when(
              data: (data) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    _buildActiveRequests(data['requests']),
                    _buildSubscriptionPlans(data['plans']),
                    _buildQuickServices(),
                    _buildRecentDocuments(),
                    _buildHelpBanner(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
              error: (_, __) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    _buildActiveRequests([]),
                    _buildSubscriptionPlans([]),
                    _buildQuickServices(),
                    _buildRecentDocuments(),
                    _buildHelpBanner(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF186ADC).withValues(alpha: 0.2), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAXFksx_2Z_r0OWPHHzOx6GKJzS_zMdwbxXfRX7bgGfzZ8QsA1p5fqMgD7YUUtnZS58sYFPfu4xzOMKXVX_4RkpQg3mvbt9oCXpNlQkqHkdeYQUGGgqiXikALYOASO4VcMgVS3wYxjUEtR6ZUnN6MzXtI4o5y45kNGt_KOa7KzpIrEka_lNARCaLKdlYblrkfQqRMnx8vaWG5sN_NM9Wut5tv9xG9cIXE7H3sWndE6rxLVYyFiGk3zGjzrWA-u9ri7XieiuRLb9GQ'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final profileAsync = ref.watch(profileProvider);
                    return profileAsync.when(
                      data: (profile) => Text(
                        profile['fullName'] ?? 'Marco Rossi',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111418),
                          letterSpacing: -0.015,
                        ),
                      ),
                      loading: () => const Text(
                        'Marco Rossi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111418),
                          letterSpacing: -0.015,
                        ),
                      ),
                      error: (_, __) => const Text(
                        'Marco Rossi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111418),
                          letterSpacing: -0.015,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () => context.go('/notifications'),
                  icon: const Icon(Icons.notifications, size: 24, color: Color(0xFF111418)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search services, forms, or documents',
            hintStyle: TextStyle(color: Color(0xFF637288)),
            prefixIcon: Icon(Icons.search, color: Color(0xFF637288)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRequests(List<dynamic> requests) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111418),
                  letterSpacing: -0.015,
                ),
              ),
              TextButton(
                onPressed: () => ref.read(navigationIndexProvider.notifier).state = 2,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF186ADC),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: requests.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No active requests',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF637288),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _buildRequestCard(
                        request['service']?['name'] ?? request['serviceName'] ?? 'Service Request',
                        request['description'] ?? 'Processing your request',
                        request['status'] ?? 'processing',
                        _getStatusColor(request['status']),
                        _getStatusIcon(request['status']),
                        _getProgress(request['status']),
                        showButton: request['status']?.toLowerCase() == 'completed' || request['status']?.toLowerCase() == 'rejected',
                        buttonText: request['status']?.toLowerCase() == 'completed' ? 'Download' : 'Upload Doc',
                        isError: request['status']?.toLowerCase() == 'rejected',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    String title,
    String description,
    String status,
    Color statusColor,
    IconData icon,
    double progress, {
    bool showButton = false,
    String? buttonText,
    bool isError = false,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: statusColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF637288),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          if (showButton)
            Container(
              width: double.infinity,
              height: 32,
              margin: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isError ? Colors.red : const Color(0xFF186ADC).withValues(alpha: 0.1),
                  foregroundColor: isError ? Colors.white : const Color(0xFF186ADC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  buttonText ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF186ADC),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickServices() {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder<List<dynamic>>(
          future: _getServiceTypes(),
          builder: (context, snapshot) {
            final serviceTypes = snapshot.data ?? [];
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111418),
                      letterSpacing: -0.015,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (serviceTypes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No services available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF637288),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: serviceTypes.map((service) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildServiceTile(
                          service['name'] ?? 'Service',
                          service['description'] ?? 'Service description',
                          _getServiceIcon(service['name']),
                          _getServiceColor(serviceTypes.indexOf(service)),
                          () => ref.read(navigationIndexProvider.notifier).state = 1,
                        ),
                      )).toList(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _getServiceTypes() async {
    try {
      final response = await ApiServiceFactory.public.getServiceTypes();
      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
  }

  IconData _getServiceIcon(String? serviceName) {
    final name = serviceName?.toLowerCase() ?? '';
    if (name.contains('isee')) return Icons.account_balance_wallet;
    if (name.contains('730') || name.contains('tax')) return Icons.request_quote;
    if (name.contains('imu') || name.contains('tari')) return Icons.apartment;
    if (name.contains('succession')) return Icons.family_restroom;
    if (name.contains('document')) return Icons.description;
    if (name.contains('certificate')) return Icons.verified;
    return Icons.business;
  }

  Color _getServiceColor(int index) {
    final colors = [
      const Color(0xFF186ADC),
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
    ];
    return colors[index % colors.length];
  }

  Widget _buildServiceTile(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111418),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF637288),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDocuments() {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder<List<dynamic>>(
          future: _getRecentDocuments(),
          builder: (context, snapshot) {
            final documents = snapshot.data ?? [];
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Documents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111418),
                      letterSpacing: -0.015,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (documents.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No documents yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF637288),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...documents.take(2).map((doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDocumentItem(
                        doc['name'] ?? 'Document.pdf',
                        'Modified ${_formatDate(doc['updatedAt'] ?? doc['createdAt'])} • ${_formatFileSize(doc['size'])}',
                      ),
                    )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _getRecentDocuments() async {
    try {
      final response = await ApiServiceFactory.customer.getDocumentsByRequest('recent');
      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Recent';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Recent';
    }
  }

  String _formatFileSize(dynamic size) {
    if (size == null) return '0 KB';
    final bytes = size is String ? int.tryParse(size) ?? 0 : size;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed': return const Color(0xFF10B981);
      case 'processing': return const Color(0xFFF59E0B);
      case 'pending': return const Color(0xFFF97316);
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed': return Icons.fact_check;
      case 'processing': return Icons.description;
      case 'pending': return Icons.schedule;
      case 'rejected': return Icons.error;
      default: return Icons.info;
    }
  }

  double _getProgress(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed': return 1.0;
      case 'processing': return 0.75;
      case 'pending': return 0.3;
      case 'rejected': return 0.0;
      default: return 0.5;
    }
  }

  Widget _buildDocumentItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111418),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF637288),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(List<dynamic> plans) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription Plans',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111418),
              letterSpacing: -0.015,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: plans.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.card_membership_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No plans available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF637288),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return _buildPlanCard(plan);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan['name'] ?? 'Plan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '€${plan['price'] ?? '0'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF186ADC),
                ),
              ),
              Text(
                '/${plan['interval'] ?? 'month'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF637288),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              plan['description'] ?? 'Plan description',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF637288),
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF186ADC),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Choose Plan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF186ADC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Need help with your taxes?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Book a free 15-minute consultation with our fiscal experts.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF186ADC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Schedule Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(80),
              ),
            ),
          ),
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}