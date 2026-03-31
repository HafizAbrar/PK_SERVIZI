import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';

class ServicePaymentScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String serviceId;
  final String? serviceRequestId;

  const ServicePaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.serviceId,
    this.serviceRequestId,
  });

  @override
  ConsumerState<ServicePaymentScreen> createState() => _ServicePaymentScreenState();
}

class _ServicePaymentScreenState extends ConsumerState<ServicePaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted && !_isDisposed) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (url) {
            if (mounted && !_isDisposed) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted && !_isDisposed &&
                error.errorType == WebResourceErrorType.hostLookup) {
              _handlePaymentCancel();
            }
          },
          onNavigationRequest: (request) {
            debugPrint('Navigation: ${request.url}');
            if (request.url.contains('success') ||
                request.url.contains('completed') ||
                request.url.contains('payment_intent')) {
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

  void _handlePaymentSuccess() {
    if (_isDisposed) return;
    if (mounted) {
      context.go('/service-request-form/${widget.serviceId}?serviceRequestId=${widget.serviceRequestId}');
    }
  }

  void _handlePaymentCancel() {
    if (_isDisposed) return;
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handlePaymentCancel();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _handlePaymentCancel,
          ),
          title: Text(
            l10n.completePayment,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
