import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/translated_text.dart';

final planDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, planId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/subscriptions/plans/$planId');
  return response.data['data'] ?? response.data ?? {};
});

class SubscriptionPlanDetailsScreen extends ConsumerStatefulWidget {
  final String planId;
  
  const SubscriptionPlanDetailsScreen({super.key, required this.planId});

  @override
  ConsumerState<SubscriptionPlanDetailsScreen> createState() => _SubscriptionPlanDetailsScreenState();
}

class _SubscriptionPlanDetailsScreenState extends ConsumerState<SubscriptionPlanDetailsScreen> {
  bool isYearly = false;
  bool isProcessing = false;

  Future<void> _purchasePlan(String planId) async {
    setState(() => isProcessing = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/api/v1/subscriptions/checkout', data: {
        'planId': planId,
      });
      
      if (mounted) {
        if (response.data['success'] == true) {
          final checkoutUrl = response.data['data']['url'] as String;
          final sessionId = response.data['data']['sessionId'] as String;
          context.push('/payment-checkout?url=${Uri.encodeComponent(checkoutUrl)}&sessionId=$sessionId&planId=$planId');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.error ?? 'Error')),
        );
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planDetailsProvider(widget.planId));
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: planAsync.when(
        data: (plan) => _buildContent(plan),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
        error: (_, __) => _buildError(),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> plan) {
    final price = isYearly ? (plan['priceAnnual'] ?? plan['price']) : (plan['priceMonthly'] ?? plan['price']);
    final priceValue = price is String ? double.tryParse(price) ?? 0.0 : (price?.toDouble() ?? 0.0);
    
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(plan),
                _buildBillingToggle(),
                _buildPriceHeader(priceValue),
                _buildFeatures(plan),
                _buildUsageLimits(plan),
              ],
            ),
          ),
        ),
        _buildFooter(plan),
      ],
    );
  }

  Widget _buildAppBar() {
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
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)?.planDetails ?? 'Plan Details',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> plan) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentColor, width: 3),
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 64,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          TranslatedText(
            plan['name'] ?? 'Professional',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          TranslatedText(
            plan['description'] ?? '',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isYearly ? AppTheme.accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)?.monthly ?? 'Monthly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: !isYearly ? AppTheme.primaryColor : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isYearly ? AppTheme.accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)?.yearlyDiscount ?? 'Yearly (-17%)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isYearly ? AppTheme.primaryColor : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHeader(double price) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF1a2e4d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: '€',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
            TextSpan(
              text: price.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: isYearly ? '/${AppLocalizations.of(context)?.year ?? 'year'}' : '/${AppLocalizations.of(context)?.month ?? 'month'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures(Map<String, dynamic> plan) {
    final features = plan['features'] as List<dynamic>? ?? [
      'Tutti i servizi Basic inclusi',
      '5 richieste di consulenza al mese',
      'Archivio documenti illimitato',
      'Assistenza prioritaria via chat',
      'Notifiche scadenze fiscali in tempo reale',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.planFeatures ?? 'Plan Features',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TranslatedText(
                    feature.toString(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUsageLimits(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.usageLimits ?? 'Usage Limits',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          _buildUsageItem('Dichiarazione IMU', 5, 5),
          const SizedBox(height: 20),
          _buildUsageItem('Calcolo ISEE', 5, 5),
          const SizedBox(height: 20),
          _buildUsageItem('Modello 730', 5, 5),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String title, int remaining, int total) {
    final progress = remaining / total;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryColor),
            ),
            Text(
              '$remaining / $total ${AppLocalizations.of(context)?.remaining ?? 'remaining'}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
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

  Widget _buildFooter(Map<String, dynamic> plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null : () => _purchasePlan(plan['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.subscribeNow ?? 'Subscribe Now',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.bolt, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'POWERED BY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF635BFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'stripe',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)?.failedToLoadPlanDetails ?? 'Failed to load plan details', style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(planDetailsProvider(widget.planId)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF186ADC),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
          ),
        ],
      ),
    );
  }
}
