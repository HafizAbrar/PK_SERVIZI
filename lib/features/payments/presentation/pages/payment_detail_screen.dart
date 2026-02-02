import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';

class PaymentDetailScreen extends ConsumerStatefulWidget {
  final String paymentId;
  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  ConsumerState<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  Map<String, dynamic>? payment;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
  }

  Future<void> _loadPaymentDetails() async {
    try {
      final response = await ApiServiceFactory.customer.getMyPayments();
      final payments = response.data as List? ?? [];
      final paymentData = payments.firstWhere(
        (p) => p['id'] == widget.paymentId,
        orElse: () => null,
      );
      
      setState(() {
        payment = paymentData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : payment == null
                ? const Center(child: Text('Payment not found'))
                : _buildPaymentDetails(),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _getStatusColor(payment!['status']),
                  child: const Icon(Icons.payment, size: 40, color: Colors.white),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Text(
                  '€${payment!['amount'] ?? '0.00'}',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  payment!['status'] ?? 'Unknown',
                  style: TextStyle(
                    color: _getStatusColor(payment!['status']),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXLarge),
          _buildDetailCard(),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Payment ID', payment!['id'] ?? 'N/A'),
            _buildDetailRow('Description', payment!['description'] ?? 'N/A'),
            _buildDetailRow('Date', payment!['date'] ?? 'N/A'),
            _buildDetailRow('Method', payment!['method'] ?? 'N/A'),
            _buildDetailRow('Reference', payment!['reference'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: AppTheme.primaryButtonStyle,
            onPressed: () => _downloadReceipt(),
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Download Receipt', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: AppTheme.secondaryButtonStyle,
            onPressed: () => _downloadInvoice(),
            icon: Icon(Icons.receipt_long, color: AppTheme.primaryColor),
            label: Text('Download Invoice', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'paid':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'failed':
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _downloadReceipt() async {
    try {
      await ApiServiceFactory.customer.getPaymentReceipt(widget.paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt download started')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading receipt: $e')),
        );
      }
    }
  }

  void _downloadInvoice() async {
    try {
      await ApiServiceFactory.customer.getPaymentInvoice(widget.paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice download started')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading invoice: $e')),
        );
      }
    }
  }
}