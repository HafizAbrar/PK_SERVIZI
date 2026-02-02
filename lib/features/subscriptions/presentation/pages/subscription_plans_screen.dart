import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';

final subscriptionPlansProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/subscriptions/plans');
  return List<Map<String, dynamic>>.from(response.data['data'] ?? response.data ?? []);
});

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  bool isYearly = false;
  String? processingPlanId;

  Future<void> _purchasePlan(String planId) async {
    setState(() => processingPlanId = planId);
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
          const SnackBar(content: Text('Failed to initiate checkout')),
        );
      }
    } finally {
      setState(() => processingPlanId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: plansAsync.when(
              data: (plans) => _buildContent(plans),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
              error: (_, __) => _buildError(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: Color(0xFF111418)),
          ),
          const Expanded(
            child: Text(
              'Subscription Plans',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> plans) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildBillingToggle(),
          _buildPlansList(plans),
          _buildFAQ(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your plan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
          SizedBox(height: 8),
          Text(
            'Select the best option for your fiscal and administrative needs.',
            style: TextStyle(fontSize: 14, color: Color(0xFF637288)),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !isYearly ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)] : null,
                ),
                child: Text(
                  'Monthly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !isYearly ? const Color(0xFF111418) : const Color(0xFF637288),
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
                  color: isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isYearly ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)] : null,
                ),
                child: Text(
                  'Yearly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isYearly ? const Color(0xFF111418) : const Color(0xFF637288),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(List<Map<String, dynamic>> plans) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: plans.map((plan) => _buildPlanCard(plan)).toList(),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isPopular = plan['popular'] == true;
    final price = isYearly ? (plan['priceAnnual'] ?? plan['price']) : (plan['priceMonthly'] ?? plan['price']);
    final priceValue = price is String ? double.tryParse(price) ?? 0.0 : (price?.toDouble() ?? 0.0);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0xFF186ADC) : const Color(0xFFDCE0E5),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isPopular 
          ? [BoxShadow(color: const Color(0xFF186ADC).withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))]
          : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan['name'] ?? 'Plan',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF186ADC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (plan['description'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                plan['description'],
                style: const TextStyle(fontSize: 14, color: Color(0xFF637288)),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${priceValue.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF111418)),
              ),
              Text(
                '/${isYearly ? 'year' : 'mo'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF637288)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: processingPlanId == plan['id'] ? null : () => _purchasePlan(plan['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF186ADC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: processingPlanId == plan['id']
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Select ${plan['name'] ?? 'Plan'}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/subscription-plan-details/${plan['id']}'),
            child: const Text(
              'View Details',
              style: TextStyle(fontSize: 14, color: Color(0xFF186ADC)),
            ),
          ),
          const SizedBox(height: 20),
          if (plan['features'] != null)
            ...List<String>.from(plan['features']).map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isPopular ? const Color(0xFF186ADC) : const Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
                    ),
                  ),
                ],
              ),
            )),
          if (plan['maxRequests'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${plan['maxRequests']} requests per month',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
                  ),
                ],
              ),
            ),
          if (plan['supportLevel'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${plan['supportLevel']} support',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDCE0E5)),
          ),
          child: Column(
            children: [
              _buildFAQItem('Can I change plans later?', 'Yes, you can upgrade or downgrade your plan at any time from your account settings. Changes will be reflected in your next billing cycle.'),
              _buildFAQItem('What is \'Consulenza dedicata\'?', 'Our Premium plan offers a dedicated fiscal expert who manages your family records and provides personalized legal and administrative guidance.'),
              _buildFAQItem('Are these prices VAT inclusive?', 'Yes, all displayed prices include relevant taxes. There are no hidden fees for the standard services included in each tier.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111418)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 14, color: Color(0xFF637288)),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          const Text('Failed to load plans', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(subscriptionPlansProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF186ADC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}