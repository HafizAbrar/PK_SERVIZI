import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../data/invoice_data_source.dart';
import '../../data/invoice_model.dart';

final invoiceDetailProvider = FutureProvider.family<Invoice, String>((ref, id) async {
  final dataSource = ref.read(invoiceDataSourceProvider);
  return await dataSource.getInvoiceById(id);
});

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final invoiceAsync = ref.watch(invoiceDetailProvider(invoiceId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xFF0A192F)),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Text(l10n.invoiceDetail, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF2D00D))),
              ],
            ),
          ),
          Expanded(
            child: invoiceAsync.when(
              data: (invoice) => _buildContent(context, invoice, l10n, ref),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF2D00D))),
              error: (_, __) => Center(child: Text(l10n.error)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Invoice invoice, AppLocalizations l10n, WidgetRef ref) {
    final date = DateTime.parse(invoice.issuedAt);
    final isPaid = invoice.status == 'paid';
    final subtotal = double.parse(invoice.amount);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2D00D).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.invoiceNumber.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(invoice.invoiceNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2D00D).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFFF2D00D).withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(isPaid ? l10n.paid.toUpperCase() : l10n.sent.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF8F9FA)),
                  const SizedBox(height: 16),
                  Text(l10n.totalAmount.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('€${invoice.amount}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0A192F))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[100]!)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.billedTo.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(invoice.billing?['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(invoice.billing?['email'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(invoice.billing?['country'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.paymentMethod.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.credit_card, size: 18),
                            const SizedBox(width: 8),
                            const Text('Stripe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(l10n.transactionCard.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[100]!)),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
                    child: Row(
                      children: [
                        Expanded(flex: 7, child: Text(l10n.description.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey))),
                        Expanded(flex: 2, child: Text(l10n.qty.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey))),
                        Expanded(flex: 3, child: Text(l10n.amount.toUpperCase(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(invoice.lineItems.first.description.split(':').first, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  Text('(${invoice.lineItems.first.description.split(':').last.trim()})', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const Expanded(flex: 2, child: Text('1', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                            Expanded(flex: 3, child: Text('€${invoice.lineItems.first.amount}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.subtotal, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                            Text('€${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${l10n.vat} (0%)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const Text('€0.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.issuedAt}:', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.transactionId}:', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(invoice.payment?['stripePaymentIntentId']?.substring(0, 15) ?? 'N/A', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
            child: ElevatedButton(
              onPressed: () => _downloadPdf(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2D00D),
                foregroundColor: const Color(0xFF0A192F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.downloadPdfReceipt.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
    try {
      final dataSource = ref.read(invoiceDataSourceProvider);
      final result = await dataSource.downloadInvoice(invoiceId);
      final pdfUrl = 'https://api.pkservizi.com${result['pdfUrl']}';
      if (await canLaunchUrl(Uri.parse(pdfUrl))) {
        await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
