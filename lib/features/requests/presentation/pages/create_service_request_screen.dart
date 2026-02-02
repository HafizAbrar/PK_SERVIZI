import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';

final createServiceRequestProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.post('/api/v1/service-requests', data: params);
  return response.data['data']['id'];
});

class CreateServiceRequestScreen extends ConsumerStatefulWidget {
  final String? serviceId;
  
  const CreateServiceRequestScreen({super.key, this.serviceId});

  @override
  ConsumerState<CreateServiceRequestScreen> createState() => _CreateServiceRequestScreenState();
}

class _CreateServiceRequestScreenState extends ConsumerState<CreateServiceRequestScreen> {
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    if (widget.serviceId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createServiceRequest();
      });
    }
  }

  Future<void> _createServiceRequest() async {
    if (_isCreating) return;
    
    setState(() => _isCreating = true);
    
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/api/v1/service-requests', data: {
        'serviceId': widget.serviceId,
        'status': 'draft',
      });
      
      final serviceRequestId = response.data['data']['id'];
      
      if (mounted) {
        // Navigate to payment with both serviceId and serviceRequestId
        context.go('/checkout?serviceId=${widget.serviceId}&serviceRequestId=$serviceRequestId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating request: $e')),
        );
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creating Request')),
      body: Center(
        child: _isCreating
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF186ADC)),
                  SizedBox(height: 16),
                  Text('Creating your service request...'),
                ],
              )
            : const Text('Preparing request...'),
      ),
    );
  }
}