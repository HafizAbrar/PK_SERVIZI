import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/widgets/translated_text.dart';

final activeSubscriptionProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  try {
    final response = await apiClient.get('/api/v1/subscriptions/my');
    return response.data['data'] ?? response.data ?? {};
  } catch (e) {
    return null;
  }
});

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionAsync = ref.watch(activeSubscriptionProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: subscriptionAsync.when(
              data: (subscription) => subscription == null 
                  ? _buildNoSubscription(context)
                  : _buildSubscriptionContent(context, subscription),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF2D00D))),
              error: (_, __) => _buildNoSubscription(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
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
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildNoSubscription(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0A192F).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.subscriptions_outlined, size: 64, color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 20),
          Text(l10n.noActiveRequests, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/subscription-plans'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2D00D),
              foregroundColor: const Color(0xFF0A192F),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.viewAll, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionContent(BuildContext context, Map<String, dynamic> subscription) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatusHeader(),
          _buildPlanCard(subscription),
          _buildBillingInfo(subscription),
          _buildUsageTracker(subscription),
          _buildFeaturesList(subscription),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
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
              color: const Color(0xFF07883b).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF07883b).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF07883b),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF07883b),
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF2D00D)),
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
              color: const Color(0xFF0A192F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 36,
              color: Color(0xFF0A192F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingInfo(Map<String, dynamic> subscription) {
    final startDate = subscription['startDate'] ?? subscription['createdAt'] ?? 'Feb 1, 2026';
    final renewalDate = subscription['renewalDate'] ?? subscription['nextBillingDate'] ?? 'Mar 1, 2026';
    final autoRenew = subscription['autoRenew'] ?? true;
    
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
                _buildBillingRow('Start Date', startDate),
                const SizedBox(height: 16),
                _buildBillingRow('Renewal Date', renewalDate),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E7EB)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-Renew',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
                        ),
                        Text(
                          'Charge my card automatically',
                          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 24,
                      decoration: BoxDecoration(
                        color: autoRenew ? const Color(0xFFF2D00D) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Align(
                        alignment: autoRenew ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                      color: const Color(0xFFF2D00D),
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
          color: Color(0xFFF2D00D),
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

  Widget _buildActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/subscription-plans'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2D00D),
                    foregroundColor: const Color(0xFF0A192F),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.plans,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                  child: const Text(
                    'Cancel Subscription',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _cancelSubscription(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel your subscription? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.delete('/api/v1/subscriptions/my');
        ref.invalidate(activeSubscriptionProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription cancelled successfully'), backgroundColor: Colors.green),
          );
          context.go('/subscription-plans');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel subscription: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
