import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_theme.dart';

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
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted && !_isDisposed) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (String url) {
            if (mounted && !_isDisposed) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted && !_isDisposed && error.errorType == WebResourceErrorType.hostLookup) {
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
    if (_isDisposed) return;
    try {
      await _controller.loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      debugPrint('Error loading payment URL: $e');
      if (mounted && !_isDisposed) _handlePaymentCancel();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isDisposed) return;
    final uri = GoRouterState.of(context).uri;
    _serviceId = uri.queryParameters['serviceId'];
    debugPrint('Extracted serviceId: $_serviceId');
  }

  void _handlePaymentSuccess() {
    if (_isDisposed) return;
    debugPrint('Payment success - serviceId: $_serviceId, serviceRequestId: ${widget.serviceRequestId}');
    if (mounted) {
      if (_serviceId != null && widget.serviceRequestId != null && widget.serviceRequestId!.isNotEmpty) {
        context.go('/service-request-form/$_serviceId?serviceRequestId=${widget.serviceRequestId}');
      } else {
        context.go('/home');
      }
    }
  }

  void _handlePaymentCancel() {
    if (_isDisposed) return;
    if (mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handlePaymentCancel();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        appBar: AppBar(
          title: const Text(
            'Payment',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Container(
          decoration: AppTheme.cardDecoration.copyWith(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
