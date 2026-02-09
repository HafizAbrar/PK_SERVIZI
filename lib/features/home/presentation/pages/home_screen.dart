import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/services/api_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'main_navigation_screen.dart';
import '../../../../core/widgets/translated_text.dart';

final homeDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final responses = await Future.wait([
      ApiServiceFactory.customer.getMyServiceRequests(),
      ApiServiceFactory.customer.getMySubscription(),
      ApiServiceFactory.customer.getMyNotifications(),
    ]);
    return {
      'requests': responses[0].data['data'] ?? [],
      'subscription': responses[1].data['data'],
      'notifications': responses[2].data['data'] ?? [],
    };
  } catch (e) {
    return {
      'requests': [],
      'subscription': null,
      'notifications': [],
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildTopNavigation(),
          Expanded(
            child: homeDataAsync.when(
              data: (data) => RefreshIndicator(
                color: const Color(0xFFF2D00D),
                onRefresh: () async {
                  ref.invalidate(homeDataProvider);
                  ref.invalidate(profileProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),
                      _buildSearchBar(),
                      _buildActiveRequests(data['requests']),
                      _buildQuickServices(),
                      _buildHelpBanner(),
                      _buildRecentDocuments(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF2D00D))),
              error: (_, __) => RefreshIndicator(
                color: const Color(0xFFF2D00D),
                onRefresh: () async => ref.invalidate(homeDataProvider),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      _buildActiveRequests([]),
                      _buildQuickServices(),
                      _buildHelpBanner(),
                      _buildRecentDocuments(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F),
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
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.premium,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF2D00D),
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'PK SERVIZI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.go('/notifications'),
                    icon: const Icon(Icons.notifications, size: 28, color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF0A192F), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(profileProvider);
                  return profileAsync.when(
                    data: (profile) => Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF2D00D), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: profile['profile']?['avatarUrl'] != null
                                ? Image.network(
                                    profile['profile']['avatarUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.person, color: Color(0xFFF2D00D), size: 24),
                                  )
                                : const Icon(Icons.person, color: Color(0xFFF2D00D), size: 24),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2D00D),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF0A192F), width: 2),
                            ),
                            child: const Icon(Icons.verified, size: 8, color: Color(0xFF0A192F)),
                          ),
                        ),
                      ],
                    ),
                    loading: () => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF2D00D), width: 2),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFFF2D00D), size: 24),
                    ),
                    error: (_, __) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF2D00D), width: 2),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFFF2D00D), size: 24),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final profileAsync = ref.watch(profileProvider);
              return profileAsync.when(
                data: (profile) => Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeBackCommaSpace,
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        profile['fullName'] ?? l10n.user,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.welcomeBackCommaSpace, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      Text(l10n.user, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                error: (_, __) => Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.welcomeBackCommaSpace, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      Text(l10n.user, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              );
            },
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
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(navigationIndexProvider.notifier).state = 1;
            }
          },
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

  Widget _buildActiveRequests(List<dynamic> requests) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.activeRequests,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
                  child: Text(
                    l10n.viewAll,
                    style: const TextStyle(
                      color: Color(0xFFF2D00D),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: requests.isEmpty
                ? _buildEmptyRequests()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _buildRequestCard(
                        request['service']?['name'] ?? request['serviceName'] ?? 'Service Request',
                        request['description'] ?? 'Processing your request',
                        request['status'] ?? 'processing',
                        _getProgress(request['status']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRequests() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A192F).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: Color(0xFF0A192F), size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noActiveRequests,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A192F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(String title, String description, String status, double progress) {
    final l10n = AppLocalizations.of(context)!;
    final isProcessing = status.toLowerCase() == 'processing';
    final isCompleted = status.toLowerCase() == 'completed';
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isProcessing ? const Color(0xFFF2D00D) : const Color(0xFF0A192F),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
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
                  color: const Color(0xFF0A192F).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.description,
                  color: const Color(0xFF0A192F),
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isProcessing 
                      ? const Color(0xFFF2D00D).withValues(alpha: 0.2) 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isProcessing ? l10n.processing : status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isProcessing ? const Color(0xFF0A192F) : Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TranslatedText(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A192F),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          TranslatedText(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2D00D),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}${l10n.percentComplete}',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServices() {
    final l10n = AppLocalizations.of(context)!;
    
    return FutureBuilder<List<dynamic>>(
      future: _getServiceTypes(),
      builder: (context, snapshot) {
        final serviceTypes = snapshot.data ?? [];
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.quickServices,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A192F),
                ),
              ),
              const SizedBox(height: 16),
              if (serviceTypes.isEmpty)
                Column(
                  children: [
                    _buildServiceListTile(l10n.isee2024, l10n.socialBenefits, Icons.family_restroom),
                    const SizedBox(height: 12),
                    _buildServiceListTile(l10n.modello730, l10n.incomeTax, Icons.receipt_long),
                    const SizedBox(height: 12),
                    _buildServiceListTile(l10n.imuTari, l10n.propertyTax, Icons.home_work),
                    const SizedBox(height: 12),
                    _buildServiceListTile(l10n.successions, l10n.inheritance, Icons.history_edu),
                  ],
                )
              else
                Column(
                  children: serviceTypes.take(4).map((service) {
                    final index = serviceTypes.indexOf(service);
                    return Column(
                      children: [
                        _buildServiceListTile(
                          service['name'] ?? 'Service',
                          _getServiceSubtitle(service['name']),
                          _getServiceIcon(service['name']),
                          service['name'],
                        ),
                        if (index < serviceTypes.take(4).length - 1) const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceListTile(String title, String subtitle, IconData icon, [dynamic backendTitle]) {
    return GestureDetector(
      onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: const Color(0xFFF2D00D), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  backendTitle != null
                      ? TranslatedText(
                          backendTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A192F),
                          ),
                        )
                      : Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A192F),
                          ),
                        ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    if (name.contains('isee')) return Icons.family_restroom;
    if (name.contains('730') || name.contains('tax')) return Icons.receipt_long;
    if (name.contains('imu') || name.contains('tari')) return Icons.home_work;
    if (name.contains('succession')) return Icons.history_edu;
    return Icons.business;
  }

  String _getServiceSubtitle(String? serviceName) {
    final l10n = AppLocalizations.of(context)!;
    final name = serviceName?.toLowerCase() ?? '';
    if (name.contains('isee')) return l10n.socialBenefits;
    if (name.contains('730') || name.contains('tax')) return l10n.incomeTax;
    if (name.contains('imu') || name.contains('tari')) return l10n.propertyTax;
    if (name.contains('succession')) return l10n.inheritance;
    return l10n.service;
  }

  Widget _buildHelpBanner() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.fiscalExpertise,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.getDedicatedConsultant,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2D00D),
                  foregroundColor: const Color(0xFF0A192F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text(
                  l10n.scheduleNow,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
            ],
          ),
          Positioned(
            right: -20,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.gavel,
                size: 120,
                color: const Color(0xFFF2D00D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocuments() {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentDocuments,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A192F),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  l10n.openFolder,
                  style: const TextStyle(
                    color: Color(0xFFF2D00D),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDocumentItem('Document_ISEE_2024.pdf', 'Oct 12, 2023 • 1.2 MB'),
          const SizedBox(height: 12),
          _buildDocumentItem('Tax_Receipt_730.pdf', 'Sep 28, 2023 • 840 KB'),
          const SizedBox(height: 12),
          _buildDocumentItem('Identity_Card_Copy.pdf', 'Aug 15, 2023 • 2.1 MB'),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: Colors.red[500],
              size: 24,
            ),
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
                    color: Color(0xFF0A192F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: const Color(0xFFF2D00D),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  double _getProgress(String? status) {
    switch (status?.toLowerCase()) {
      case 'payment_pending': return 0.10;
      case 'awaiting_form': return 0.20;
      case 'awaiting_documents': return 0.40;
      case 'draft': return 0.50;
      case 'ready_to_submit': return 0.60;
      case 'submitted': return 1.0;
      case 'processing': return 0.70;
      case 'completed': return 1.0;
      default: return 0.5;
    }
  }
}
