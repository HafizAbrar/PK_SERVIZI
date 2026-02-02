import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';

final serviceRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ApiServiceFactory.customer.getMyServiceRequests();
  final data = response.data as Map<String, dynamic>;
  return List<Map<String, dynamic>>.from(data['data'] ?? []);
});

class ServiceRequestsScreen extends ConsumerStatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  ConsumerState<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends ConsumerState<ServiceRequestsScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(serviceRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Column(
                children: [
                  _buildSummaryStats(),
                  _buildSearchBar(),
                  _buildFilterChips(),
                  _buildSectionHeader(),
                  Expanded(
                    child: requestsAsync.when(
                      data: (requests) => _buildRequestsList(requests),
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8).withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back_ios, size: 24),
            ),
          ),
          const Expanded(
            child: Text(
              'My Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111418),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer(builder: (context, ref, child) {
                    final requestsAsync = ref.watch(serviceRequestsProvider);
                    return requestsAsync.when(
                      data: (requests) {
                        final activeCount = requests.where((r) => r['status'] != 'completed').length;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              activeCount.toString(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111418),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '+1',
                              style: TextStyle(
                                color: Color(0xFF07883B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Text('...', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      error: (_, __) => const Text('0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ATTENTION',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer(builder: (context, ref, child) {
                    final requestsAsync = ref.watch(serviceRequestsProvider);
                    return requestsAsync.when(
                      data: (requests) {
                        final attentionCount = requests.where((r) => r['status'] == 'awaiting_documents').length;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              attentionCount.toString(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '0',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Text('...', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                      error: (_, __) => const Text('0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Search ID or service type...',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Processing', 'Completed'];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF186ADC) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF186ADC) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF186ADC).withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF111418),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111418),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Color(0xFF186ADC),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> requests) {
    final filteredRequests = _filterRequests(requests);
    
    if (filteredRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 16),
            Text('No service requests', style: TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) => _buildRequestCard(filteredRequests[index]),
    );
  }

  List<Map<String, dynamic>> _filterRequests(List<Map<String, dynamic>> requests) {
    if (selectedFilter == 'All') return requests;
    
    return requests.where((request) {
      final status = request['status'] ?? '';
      switch (selectedFilter) {
        case 'Pending':
          return status == 'awaiting_form' || status == 'payment_pending';
        case 'Processing':
          return status == 'processing' || status == 'awaiting_documents';
        case 'Completed':
          return status == 'completed';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'] ?? 'pending';
    final needsAttention = status == 'awaiting_documents' || status == 'rejected';
    
    return GestureDetector(
      onTap: () => context.push('/service-requests/${request['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REF: #${request['id']?.toString().toUpperCase().substring(0, 8) ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request['service']?['name'] ?? 'Income Tax Return 2023',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111418),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(status),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _getStatusBorderColor(status)),
                ),
                child: Center(
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusTextColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Text(
                'Submitted on ${_formatDate(request['createdAt'])}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (needsAttention) ..._buildNeedsAttentionSection(status),
          if (status == 'processing') ..._buildProcessingSection(),
          if (status == 'completed') ..._buildCompletedSection(),
          if (status == 'payment_pending') ..._buildPendingSection(),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildNeedsAttentionSection(String status) {
    return [
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildTimelineDot(true, false),
                _buildTimelineDot(true, false),
                _buildTimelineDot(false, true),
                _buildTimelineDot(false, false, showNumber: '4'),
              ],
            ),
            const Row(
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    color: Color(0xFF186ADC),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 14, color: Color(0xFF186ADC)),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildProcessingSection() {
    return [
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.65,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF186ADC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviewing documents...',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  '65%',
                  style: TextStyle(
                    color: Color(0xFF186ADC),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildCompletedSection() {
    return [
      const SizedBox(height: 16),
      const Row(
        children: [
          Icon(Icons.verified, size: 18, color: Color(0xFF10B981)),
          SizedBox(width: 8),
          Text(
            'Finalized on Oct 15, 2023',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildPendingSection() {
    return [
      const SizedBox(height: 16),
      const Row(
        children: [
          Icon(Icons.history, size: 18, color: Color(0xFF9CA3AF)),
          SizedBox(width: 8),
          Text(
            'Awaiting initial verification',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildTimelineDot(bool isCompleted, bool needsAttention, {String? showNumber}) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: needsAttention 
            ? const Color(0xFFEF4444)
            : isCompleted 
                ? const Color(0xFF186ADC)
                : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: showNumber != null
          ? Center(
              child: Text(
                showNumber,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Icon(
              needsAttention 
                  ? Icons.priority_high
                  : Icons.check,
              size: 12,
              color: Colors.white,
            ),
    );
  }



  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'awaiting_documents':
      case 'rejected':
        return const Color(0xFFFEE2E2);
      case 'processing':
      case 'awaiting_form':
        return const Color(0xFFDCEFFF);
      case 'completed':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'awaiting_documents':
      case 'rejected':
        return const Color(0xFFFECACA);
      case 'processing':
      case 'awaiting_form':
        return const Color(0xFFBFDBFE);
      case 'completed':
        return const Color(0xFFBBF7D0);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'awaiting_documents':
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'processing':
      case 'awaiting_form':
        return const Color(0xFF186ADC);
      case 'completed':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'awaiting_documents':
        return 'Needs Attention';
      case 'awaiting_form':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}