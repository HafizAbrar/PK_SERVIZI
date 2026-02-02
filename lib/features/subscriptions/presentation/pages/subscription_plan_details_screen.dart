import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';

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
          const SnackBar(content: Text('Failed to initiate checkout')),
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
      backgroundColor: Colors.white,
      body: planAsync.when(
        data: (plan) => _buildContent(plan),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
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
              'Dettagli Piano',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: const Color(0xFF186ADC).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 64,
              color: Color(0xFF186ADC),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            plan['name'] ?? 'Professional',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            plan['description'] ?? 'Piano professionale per utenti con esigenze avanzate',
            style: const TextStyle(fontSize: 16, color: Color(0xFF637288)),
            textAlign: TextAlign.center,
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
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: !isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !isYearly ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)] : null,
                ),
                child: Text(
                  'Mensile',
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
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isYearly ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)] : null,
                ),
                child: Text(
                  'Annuale (-17%)',
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

  Widget _buildPriceHeader(double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: '€${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111418),
              ),
            ),
            TextSpan(
              text: isYearly ? '/anno' : '/mese',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Color(0xFF9CA3AF),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Caratteristiche del piano',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF186ADC), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature.toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageLimits(Map<String, dynamic> plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Limiti di utilizzo servizi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            children: [
              _buildUsageItem('Dichiarazione IMU', 5, 5),
              const SizedBox(height: 20),
              _buildUsageItem('Calcolo ISEE', 5, 5),
              const SizedBox(height: 20),
              _buildUsageItem('Modello 730', 5, 5),
            ],
          ),
        ),
      ],
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
            ),
            Text(
              '$remaining / $total rimaste',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF186ADC)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF186ADC),
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
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null : () => _purchasePlan(plan['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF186ADC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Abbonati Ora',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.bolt, size: 20),
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
          const Text('Failed to load plan details', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(planDetailsProvider(widget.planId)),
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