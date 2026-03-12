import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/widgets/translated_text.dart';
import 'subscription_plans_screen.dart';

final subscriptionPlansProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/subscriptions/plans');
  return List<Map<String, dynamic>>.from(response.data['data'] ?? response.data ?? []);
});

final activeSubscriptionProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  try {
    final response = await apiClient.get('/api/v1/subscriptions/my');
    debugPrint('Subscription API response: ${response.data}');
    debugPrint('Subscription response status: ${response.statusCode}');
    final data = response.data['data'];
    debugPrint('Subscription data field: $data');
    debugPrint('Subscription data type: ${data.runtimeType}');
    debugPrint('Subscription data is null: ${data == null}');
    debugPrint('Subscription data is Map: ${data is Map<String, dynamic>}');
    
    if (data is Map<String, dynamic>) {
      debugPrint('Subscription data keys: ${data.keys}');
      debugPrint('Subscription provider returning valid data');
      return data;
    } else if (data is List) {
      debugPrint('Data is a List, taking first element');
      return data.isNotEmpty && data.first is Map<String, dynamic> ? data.first : null;
    }
    
    debugPrint('Subscription provider returning null');
    return null;
  } catch (e, stackTrace) {
    debugPrint('Error loading active subscription: $e');
    debugPrint('Stack trace: $stackTrace');
    return null;
  }
});

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionAsync = ref.watch(activeSubscriptionProvider);
    
    return WillPopScope(
      onWillPop: () async {
        debugPrint('WillPopScope: Refreshing subscription data...');
        ref.invalidate(activeSubscriptionProvider);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Column(
          children: [
            _buildHeader(context, l10n, ref),
            Expanded(
              child: subscriptionAsync.when(
                data: (subscription) => subscription == null 
                    ? _buildNoSubscription(context)
                    : _buildSubscriptionContent(context, subscription, ref),
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                error: (_, __) => _buildNoSubscription(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
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
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              l10n.mySubscriptions,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              debugPrint('Refreshing subscription data from app bar...');
              ref.refresh(activeSubscriptionProvider);
            },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscription(BuildContext context) {
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
            child: const Icon(Icons.subscriptions_outlined, size: 64, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 20),
          const Text('No Active Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/subscription-plans'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View Plans', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionContent(BuildContext context, Map<String, dynamic> subscription, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatusHeader(subscription),
          _buildPlanCard(subscription),
          _buildBillingInfo(subscription),
          _buildUsageTracker(subscription),
          _buildFeaturesList(subscription),
          _buildActions(context, subscription),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(Map<String, dynamic> subscription) {
    final status = subscription['status'] ?? 'active';
    final isActive = status.toLowerCase() == 'active';
    final statusColor = isActive ? const Color(0xFF07883b) : const Color(0xFFEF4444);
    final statusText = isActive ? 'ACTIVE' : status.toUpperCase();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> subscription) {
    final planName = subscription['plan']?['name'] ?? subscription['planName'] ?? 'Basic Plan';
    final price = subscription['plan']?['priceMonthly'] ?? subscription['price'] ?? '9.99';
    final description = subscription['plan']?['description'] ?? subscription['description'] ?? 'Piano base per utenti individuali con servizi essenziali.';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  planName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '€$price',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                      ),
                      const TextSpan(
                        text: '/monthly',
                        style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                TranslatedText(
                  description,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF637288)),
                ),
              ],
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 36,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingInfo(Map<String, dynamic> subscription) {
    final startDate = subscription['startDate'] ?? 'N/A';
    final endDate = subscription['endDate'] ?? subscription['renewalDate'] ?? subscription['nextBillingDate'] ?? 'N/A';
    final status = subscription['status'] ?? 'active';
    final billingCycle = subscription['billingCycle'] ?? 'monthly';
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildBillingRow('Start Date', _formatDate(startDate)),
                const SizedBox(height: 16),
                _buildBillingRow('End Date', _formatDate(endDate)),
                const SizedBox(height: 16),
                _buildBillingRow('Billing Cycle', billingCycle.toUpperCase()),
                const SizedBox(height: 16),
                _buildBillingRow('Status', status.toUpperCase()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null || date == 'N/A') return 'N/A';
    try {
      if (date is String) {
        final dateTime = DateTime.parse(date);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
    }
    return date.toString();
  }

  Widget _buildBillingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
        ),
      ],
    );
  }

  Widget _buildUsageTracker(Map<String, dynamic> subscription) {
    final serviceLimits = subscription['plan']?['serviceLimits'] ?? {};
    final imuLimit = serviceLimits['imu'] ?? 0;
    final iseeLimit = serviceLimits['isee'] ?? 0;
    final modello730Limit = serviceLimits['modello730'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usage',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildUsageItem('IMU', 0, imuLimit),
              const SizedBox(height: 16),
              _buildUsageItem('ISEE', 0, iseeLimit),
              const SizedBox(height: 16),
              _buildUsageItem('Modello 730', 0, modello730Limit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String title, int used, int total) {
    final isUnlimited = total == -1;
    final progress = isUnlimited ? 0.0 : (total > 0 ? used / total : 0.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
            ),
            Text(
              isUnlimited ? '$used/∞' : '$used/$total',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: isUnlimited
              ? Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF07883b),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(Map<String, dynamic> subscription) {
    final features = subscription['plan']?['features'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Features',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          const SizedBox(height: 8),
          Column(
            children: features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildFeatureItem(feature.toString()),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: AppTheme.accentColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TranslatedText(
            feature,
            style: const TextStyle(fontSize: 14, color: Color(0xFF111418)),
          ),
        ),
      ],
    );
  }


  Widget _buildActions(BuildContext context, Map<String, dynamic> subscription) {
    final status = subscription['status'] ?? 'active';
    final isCancelled = status.toLowerCase() == 'cancelled';
    final currentPlanId = subscription['planId'] ?? subscription['plan']?['id'];
    
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              if (!isCancelled)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showUpgradeDowngradeOptions(context, ref, currentPlanId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Change Plan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (!isCancelled) const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelSubscription(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isCancelled ? 'Reactivate Subscription' : 'Cancel Subscription',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpgradeDowngradeOptions(BuildContext context, WidgetRef ref, String? currentPlanId) {
    final status = (context as Element).widget is SubscriptionScreen ? 'active' : 'cancelled';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Change Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final plansAsync = ref.watch(subscriptionPlansProvider);
                    return plansAsync.when(
                      data: (plans) => ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: plans.map((plan) => _buildPlanChangeOption(plan, currentPlanId, ref, context)).toList(),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                      error: (_, __) => Center(
                        child: Text(
                          'Failed to load plans',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanChangeOption(Map<String, dynamic> plan, String? currentPlanId, WidgetRef ref, BuildContext context) {
    final isCurrentPlan = plan['id'] == currentPlanId;
    final planName = plan['name'] ?? 'Plan';
    final price = plan['priceMonthly'] ?? plan['price'] ?? '0';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentPlan ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlan ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  planName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '€$price/month',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentPlan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => _changePlan(context, ref, plan['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Change',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _changePlan(BuildContext context, WidgetRef ref, String newPlanId) async {
    try {
      final subscriptionAsync = ref.watch(activeSubscriptionProvider);
      final currentSubscription = subscriptionAsync.maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );
      
      final currentPlanId = currentSubscription?['planId'];
      final plansAsync = ref.watch(subscriptionPlansProvider);
      final plans = plansAsync.maybeWhen(
        data: (data) => data,
        orElse: () => <Map<String, dynamic>>[],
      );
      
      final currentPlan = plans.firstWhere((p) => p['id'] == currentPlanId, orElse: () => {});
      final newPlan = plans.firstWhere((p) => p['id'] == newPlanId, orElse: () => {});
      
      debugPrint('Current plan: ${currentPlan['name']} (${currentPlan['id']})');
      debugPrint('New plan: ${newPlan['name']} (${newPlan['id']})');
      
      final currentPrice = double.tryParse(currentPlan['priceMonthly']?.toString() ?? '0') ?? 0.0;
      final newPrice = double.tryParse(newPlan['priceMonthly']?.toString() ?? '0') ?? 0.0;
      
      final isUpgrade = newPrice > currentPrice;
      var endpoint = isUpgrade ? '/api/v1/subscriptions/upgrade' : '/api/v1/subscriptions/downgrade';
      
      debugPrint('Current plan price: €$currentPrice');
      debugPrint('New plan price: €$newPrice');
      debugPrint('Is upgrade: $isUpgrade');
      debugPrint('Using endpoint: $endpoint');
      debugPrint('New plan ID: $newPlanId');
      
      final apiClient = ref.read(apiClientProvider);
      debugPrint('Changing subscription plan to: $newPlanId');
      
      try {
        final response = await apiClient.post(endpoint, data: {'newPlanId': newPlanId});
        debugPrint('Change plan response: ${response.data}');
        debugPrint('Change plan status: ${response.statusCode}');
        
        if (response.data['success'] == true) {
          final checkoutUrl = response.data['data']?['checkoutUrl'] as String?;
          final sessionId = response.data['data']?['sessionId'] as String?;
          
          if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
            if (context.mounted) {
              Navigator.pop(context);
              context.push('/payment-checkout?url=${Uri.encodeComponent(checkoutUrl)}&sessionId=$sessionId&planId=$newPlanId');
            }
          } else {
            ref.invalidate(activeSubscriptionProvider);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isUpgrade ? 'Plan upgraded successfully' : 'Plan downgraded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      } catch (endpointError) {
        if (endpointError is DioException && 
            endpointError.response?.statusCode == 400 &&
            endpointError.response?.data['message']?.toString().contains('use upgrade instead') == true) {
          debugPrint('Downgrade failed, trying upgrade endpoint instead...');
          endpoint = '/api/v1/subscriptions/upgrade';
          final response = await apiClient.post(endpoint, data: {'newPlanId': newPlanId});
          debugPrint('Retry with upgrade - response: ${response.data}');
          
          if (response.data['success'] == true) {
            final checkoutUrl = response.data['data']?['checkoutUrl'] as String?;
            final sessionId = response.data['data']?['sessionId'] as String?;
            
            if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
              if (context.mounted) {
                Navigator.pop(context);
                context.push('/payment-checkout?url=${Uri.encodeComponent(checkoutUrl)}&sessionId=$sessionId&planId=$newPlanId');
              }
            } else {
              ref.invalidate(activeSubscriptionProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan changed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          }
        } else {
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error changing plan: $e');
      debugPrint('Stack trace: $stackTrace');
      if (e is DioException) {
        debugPrint('Response data: ${e.response?.data}');
        debugPrint('Response status: ${e.response?.statusCode}');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  static Future<void> _cancelSubscription(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionAsync = ref.watch(activeSubscriptionProvider);
    
    final subscription = subscriptionAsync.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    
    final status = subscription?['status'] ?? 'active';
    final isCancelled = status.toLowerCase() == 'cancelled';
    
    final title = isCancelled ? 'Reactivate Subscription' : 'Cancel Subscription';
    final message = isCancelled 
        ? 'Are you sure you want to reactivate your subscription?'
        : 'Are you sure you want to cancel your subscription? This action cannot be undone.';
    final confirmText = isCancelled ? 'Yes, Reactivate' : 'Yes, Cancel';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: isCancelled ? Colors.green : Colors.red),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final apiClient = ref.read(apiClientProvider);
        final endpoint = isCancelled ? '/api/v1/subscriptions/reactivate' : '/api/v1/subscriptions/cancel';
        debugPrint('${isCancelled ? 'Reactivating' : 'Cancelling'} subscription...');
        final response = await apiClient.post(endpoint, data: {});
        debugPrint('${isCancelled ? 'Reactivate' : 'Cancel'} subscription response: ${response.data}');
        debugPrint('${isCancelled ? 'Reactivate' : 'Cancel'} subscription status: ${response.statusCode}');
        
        ref.invalidate(activeSubscriptionProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCancelled ? 'Subscription reactivated successfully' : 'Subscription cancelled successfully'),
              backgroundColor: isCancelled ? Colors.green : Colors.red,
            ),
          );
          if (!isCancelled) {
            context.go('/subscription-plans');
          }
        }
      } catch (e, stackTrace) {
        debugPrint('Error ${isCancelled ? 'reactivating' : 'cancelling'} subscription: $e');
        debugPrint('Stack trace: $stackTrace');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to ${isCancelled ? 'reactivate' : 'cancel'} subscription: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
