import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/services/api_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'main_navigation_screen.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/theme/app_theme.dart';

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
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final PageController _requestsPageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  int _currentRequestPage = 0;
  Timer? _autoScrollTimer;
  Timer? _requestsAutoScrollTimer;
  List<dynamic>? _cachedServiceTypes;
  List<dynamic>? _cachedPlans;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _cachedServiceTypes = await _getServiceTypes();
    _cachedPlans = await _getSubscriptionPlans();
    if (mounted) {
      setState(() {});
      if (_cachedPlans != null && _cachedPlans!.isNotEmpty) {
        _autoScrollTimer = _startAutoScroll(_pageController, _cachedPlans!.length, (page) => setState(() => _currentPage = page));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _requestsPageController.dispose();
    _autoScrollTimer?.cancel();
    _requestsAutoScrollTimer?.cancel();
    super.dispose();
  }

  Timer _startAutoScroll(PageController controller, int itemCount, Function(int) onPageChanged) {
    return Timer.periodic(const Duration(seconds: 3), (timer) {
      if (controller.hasClients && itemCount > 0) {
        final nextPage = (controller.page?.round() ?? 0) + 1;
        controller.animateToPage(
          nextPage % itemCount,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
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
                color: const Color(0xFF1E3A5F),
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
                      _buildSubscriptionPlans(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F))),
              error: (_, __) => RefreshIndicator(
                color: const Color(0xFF1E3A5F),
                onRefresh: () async => ref.invalidate(homeDataProvider),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      _buildActiveRequests([]),
                      _buildQuickServices(),
                      _buildSubscriptionPlans(),
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
                      color: Color(0xFF1E3A5F),
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
                        border: Border.all(color: AppTheme.primaryColor, width: 2),
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
                            border: Border.all(color: const Color(0xFF1E3A5F), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: profile['profile']?['avatarUrl'] != null
                                ? Image.network(
                                    profile['profile']['avatarUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.person, color: Color(0xFF1E3A5F), size: 24),
                                  )
                                : const Icon(Icons.person, color: Color(0xFF1E3A5F), size: 24),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A5F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primaryColor, width: 2),
                            ),
                            child: const Icon(Icons.verified, size: 8, color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    loading: () => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1E3A5F), width: 2),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF1E3A5F), size: 24),
                    ),
                    error: (_, __) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1E3A5F), width: 2),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF1E3A5F), size: 24),
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
    
    if (requests.isNotEmpty && _requestsAutoScrollTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _requestsPageController.hasClients) {
          _requestsAutoScrollTimer = _startAutoScroll(_requestsPageController, requests.length, (page) => setState(() => _currentRequestPage = page));
        }
      });
    }
    
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
                    color: AppTheme.primaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
                  child: Text(
                    l10n.viewAll,
                    style: const TextStyle(
                      color: Color(0xFF1E3A5F),
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
                : PageView.builder(
                    controller: _requestsPageController,
                    onPageChanged: (index) {
                      setState(() => _currentRequestPage = index);
                      _requestsAutoScrollTimer?.cancel();
                      _requestsAutoScrollTimer = _startAutoScroll(_requestsPageController, requests.length, (page) => setState(() => _currentRequestPage = page));
                    },
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildRequestCard(
                          request['service']?['name'] ?? request['serviceName'] ?? 'Service Request',
                          request['description'] ?? 'Processing your request',
                          request['status'] ?? 'processing',
                          _getProgress(request['status']),
                        ),
                      );
                    },
                  ),
          ),
          if (requests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                requests.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentRequestPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentRequestPage == index ? const Color(0xFF1E3A5F) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
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
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noActiveRequests,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E3A5F),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.description,
              size: 100,
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.description,
                      color: const Color(0xFF1E3A5F),
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isProcessing 
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFF1E3A5F).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isProcessing ? l10n.processing : status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
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
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              TranslatedText(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}${l10n.percentComplete}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServices() {
    final l10n = AppLocalizations.of(context)!;
    final serviceTypes = _cachedServiceTypes ?? [];
    
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
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          if (serviceTypes.isEmpty)
            Column(
              children: [
                _buildServiceListTile(l10n.isee2024, l10n.socialBenefits, Icons.family_restroom, true),
                const SizedBox(height: 12),
                _buildServiceListTile(l10n.modello730, l10n.incomeTax, Icons.receipt_long, true),
                const SizedBox(height: 12),
                _buildServiceListTile(l10n.imuTari, l10n.propertyTax, Icons.home_work, true),
                const SizedBox(height: 12),
                _buildServiceListTile(l10n.successions, l10n.inheritance, Icons.history_edu, true),
              ],
            )
          else
            Column(
              children: serviceTypes.take(4).map((service) {
                final index = serviceTypes.indexOf(service);
                final isActive = service['isActive'] ?? true;
                return Column(
                  children: [
                    _buildServiceListTile(
                      service['name'] ?? 'Service',
                      service['description'] ?? '',
                      _getServiceIcon(service['name']),
                      isActive,
                    ),
                    if (index < serviceTypes.take(4).length - 1) const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceListTile(String title, String subtitle, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: isActive ? () => ref.read(navigationIndexProvider.notifier).state = 1 : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? Colors.grey[100]! : Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/logos/APP LOGO.jpeg',
                  width: 70,
                  height: 30,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF1E3A5F).withOpacity(0.2) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isActive ? AppTheme.primaryColor : Colors.grey[600],
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildSubscriptionPlans() {
    final l10n = AppLocalizations.of(context)!;
    final plans = _cachedPlans ?? [];
    if (plans.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.chooseYourPlan,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(
                    color: Color(0xFF1E3A5F),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _autoScrollTimer?.cancel();
              _autoScrollTimer = _startAutoScroll(_pageController, plans.length, (page) => setState(() => _currentPage = page));
            },
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final isPopular = plan['name'] == 'Premium';
              return _buildPlanCard(plan, isPopular, l10n);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            plans.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFF1E3A5F) : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isPopular, AppLocalizations l10n) {
    final priceMonthly = plan['priceMonthly'] ?? '0.00';
    final priceValue = double.tryParse(priceMonthly) ?? 0.0;
    final features = (plan['features'] as List?) ?? [];
    
    return GestureDetector(
      onTap: () => context.push('/subscription-plan-details/${plan['id']}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1E3A5F),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.star,
                size: 100,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.mostPopular,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  if (isPopular) const SizedBox(height: 8),
                  Text(
                    plan['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '€',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      Text(
                        priceValue.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '/${l10n.month}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: features.map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: const Color(0xFF1E3A5F),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/subscription-plan-details/${plan['id']}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        foregroundColor: AppTheme.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        l10n.select,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
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

  Future<List<dynamic>> _getSubscriptionPlans() async {
    try {
      final response = await ApiServiceFactory.public.getSubscriptionPlans();
      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
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





