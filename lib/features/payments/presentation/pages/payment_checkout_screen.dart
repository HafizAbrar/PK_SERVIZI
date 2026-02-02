import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final String paymentUrl;
  final String? serviceRequestId;
  
  const PaymentCheckoutScreen({
    super.key, 
    required this.paymentUrl,
    this.serviceRequestId,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _serviceId;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted && error.errorType == WebResourceErrorType.hostLookup) {
              _handlePaymentCancel();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation request: ${request.url}');
            if (request.url.contains('success') || request.url.contains('payment_intent')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }
            if (request.url.contains('cancel')) {
              _handlePaymentCancel();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    try {
      await _controller.loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      debugPrint('Error loading payment URL: $e');
      if (mounted) _handlePaymentCancel();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract serviceId from current route
    final uri = GoRouterState.of(context).uri;
    _serviceId = uri.queryParameters['serviceId'];
    debugPrint('Extracted serviceId: $_serviceId');
    debugPrint('Full URI: $uri');
  }

  void _handlePaymentSuccess() {
    debugPrint('Payment success - serviceId: $_serviceId, serviceRequestId: ${widget.serviceRequestId}');
    if (mounted) {
      if (_serviceId != null) {
        // Navigate to form with serviceId, serviceRequestId will be fetched from the checkout screen context
        context.go('/service-request-form/$_serviceId?serviceRequestId=${widget.serviceRequestId ?? ''}');
      } else {
        context.go('/home');
      }
    }
  }

  void _handlePaymentCancel() {
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF186ADC),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF186ADC)),
            ),
        ],
      ),
    );
  }
}