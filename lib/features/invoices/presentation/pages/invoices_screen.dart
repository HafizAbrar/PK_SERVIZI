import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../data/invoice_data_source.dart';
import '../../data/invoice_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

final invoicesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dataSource = ref.read(invoiceDataSourceProvider);
  final invoices = await dataSource.getInvoices();
  final payments = await dataSource.getPayments();
  return {'invoices': invoices['invoices'], 'payments': payments['payments']};
});

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final invoicesAsync = ref.watch(invoicesProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: AppTheme.primaryColor, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/home'),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Text(l10n.invoices, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                const Spacer(),
                profileAsync.when(
                  data: (profile) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.accentColor.withOpacity(0.3))),
                    child: ClipOval(
                      child: profile['profile']?['avatarUrl'] != null
                          ? Image.network(profile['profile']['avatarUrl'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppTheme.accentColor))
                          : const Icon(Icons.person, color: AppTheme.accentColor),
                    ),
                  ),
                  loading: () => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.accentColor.withOpacity(0.3))),
                    child: const Icon(Icons.person, color: AppTheme.accentColor),
                  ),
                  error: (_, __) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.accentColor.withOpacity(0.3))),
                    child: const Icon(Icons.person, color: AppTheme.accentColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: invoicesAsync.when(
              data: (result) => _buildInvoicesList(context, result['invoices'], result['payments'], l10n),
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
              error: (_, __) => Center(child: Text(l10n.error)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList(BuildContext context, List<Invoice> invoices, List<Payment> payments, AppLocalizations l10n) {
    final servicePayments = payments.where((p) => p.serviceRequestId != null && p.status == 'completed').toList();
    
    final totalPaid = invoices.fold(0.0, (sum, i) => sum + double.parse(i.amount)) + 
                      servicePayments.fold(0.0, (sum, p) => sum + double.parse(p.amount));
    final recentInvoiceNumber = invoices.isNotEmpty ? invoices.first.invoiceNumber : '';

    List<dynamic> filteredItems = [];
    if (_selectedCategory == 'all') {
      filteredItems = [...invoices, ...servicePayments];
    } else if (_selectedCategory == 'plan') {
      filteredItems = invoices;
    } else {
      filteredItems = servicePayments;
    }

    if (invoices.isEmpty && servicePayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Invoice History is Empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'No invoices or payments found',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF1a2e4d)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
          ),
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Positioned(right: -20, top: -20, child: Icon(Icons.account_balance, size: 120, color: Colors.white.withOpacity(0.1))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.fiscalYear} ${DateTime.now().year}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('€${totalPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'serif')),
                      const SizedBox(width: 8),
                      Text(l10n.totalPaid, style: const TextStyle(fontSize: 12, color: AppTheme.accentColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, color: AppTheme.accentColor, size: 14),
                        const SizedBox(width: 8),
                        Text('${l10n.recent}: ', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        Text(recentInvoiceNumber, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('all', l10n.all, invoices.length + servicePayments.length),
              const SizedBox(width: 12),
              _buildCategoryChip('plan', 'Plan Invoices', invoices.length),
              const SizedBox(width: 12),
              _buildCategoryChip('service', 'Service Invoices', servicePayments.length),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.invoiceHistory, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
            const Icon(Icons.filter_list, color: Colors.grey, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        ...filteredItems.map((item) {
          if (item is Invoice) {
            return _buildInvoiceCard(context, item, l10n);
          } else {
            return _buildPaymentCard(context, item as Payment, l10n);
          }
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCategoryChip(String category, String label, int count) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.accentColor : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Invoice invoice, AppLocalizations l10n) {
    final date = DateTime.parse(invoice.issuedAt);
    final isPaid = invoice.status == 'paid';
    return GestureDetector(
      onTap: () => context.push('/invoices/${invoice.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.invoiceNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontFamily: 'serif')),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                      Text('€${invoice.amount}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(invoice.lineItems.first.description, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPaid ? AppTheme.accentColor.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: isPaid ? AppTheme.accentColor : Colors.grey)),
                        const SizedBox(width: 6),
                        Text(isPaid ? l10n.paid : l10n.sent, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isPaid ? AppTheme.primaryColor : Colors.grey[600], letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.2)),
              ),
              child: const Icon(Icons.picture_as_pdf, color: AppTheme.accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment, AppLocalizations l10n) {
    final date = DateTime.parse(payment.paidAt ?? payment.createdAt);
    final serviceName = payment.metadata?['serviceName'] ?? payment.description;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontFamily: 'serif')),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    Text('€${payment.amount}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(payment.description, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.accentColor)),
                      const SizedBox(width: 6),
                      Text(l10n.paid, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.2)),
              ),
              child: const Icon(Icons.more_vert, color: AppTheme.accentColor),
            ),
            onSelected: (value) => _handlePaymentAction(context, payment.id, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'receipt', child: Row(children: [Icon(Icons.receipt, size: 20), SizedBox(width: 12), Text('Download Payment Receipt')])),
              const PopupMenuItem(value: 'invoice', child: Row(children: [Icon(Icons.description, size: 20), SizedBox(width: 12), Text('Generate Formal Invoice')])),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePaymentAction(BuildContext context, String paymentId, String action) async {
    try {
      if (action == 'receipt') {
        final apiClient = ref.read(apiClientProvider);
        final response = await apiClient.dio.get(
          '/api/v1/payments/$paymentId/receipt',
          options: Options(responseType: ResponseType.bytes),
        );
        
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/receipt_$paymentId.pdf');
        await file.writeAsBytes(response.data);
        
        final result = await OpenFile.open(file.path);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        }
      } else if (action == 'invoice') {
        final dataSource = ref.read(invoiceDataSourceProvider);
        final result = await dataSource.generatePaymentInvoice(paymentId);
        final url = 'https://api.pkservizi.com${result['invoiceUrl']}';
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

}

