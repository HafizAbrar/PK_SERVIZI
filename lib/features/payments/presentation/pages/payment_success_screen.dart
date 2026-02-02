import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String? requestId;
  final String? serviceId;
  
  const PaymentSuccessScreen({
    super.key,
    this.requestId,
    this.serviceId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate after showing success message
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (widget.requestId != null && widget.serviceId != null) {
          // Navigate to service request form after payment
          context.go('/service-request-form/${widget.serviceId}?serviceRequestId=${widget.requestId}');
        } else if (widget.requestId != null) {
          // Navigate to service request detail if only requestId is available
          context.go('/service-requests/${widget.requestId}');
        } else {
          // Navigate to service requests list
          context.go('/service-requests');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXLarge),
              
              // Success Title
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTheme.fontSizeXXLarge,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingMedium),
              
              // Success Message
              Text(
                widget.requestId != null
                    ? 'Your payment has been processed successfully.\nRequest ID: ${widget.requestId}'
                    : 'Your payment has been processed successfully.\nYou will receive a confirmation email shortly.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: AppTheme.fontSizeRegular,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingXLarge),
              
              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (widget.requestId != null && widget.serviceId != null) {
                          context.go('/service-request-form/${widget.serviceId}?serviceRequestId=${widget.requestId}');
                        } else if (widget.requestId != null) {
                          context.go('/service-requests/${widget.requestId}');
                        } else {
                          context.go('/service-requests');
                        }
                      },
                      child: Text(
                        widget.requestId != null && widget.serviceId != null
                            ? 'Fill Service Form'
                            : widget.requestId != null 
                                ? 'View Request Details'
                                : 'View My Requests',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeRegular,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => context.go('/home'),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeRegular,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}