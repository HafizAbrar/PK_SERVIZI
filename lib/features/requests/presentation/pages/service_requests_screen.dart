import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../generated/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final requestsAsync = ref.watch(serviceRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(l10n),
          Expanded(
            child: requestsAsync.when(
              data: (requests) => RefreshIndicator(
                color: const Color(0xFFF2D00D),
                onRefresh: () async => ref.invalidate(serviceRequestsProvider),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSummaryStats(requests, l10n),
                      _buildSearchBar(l10n),
                      _buildFilterChips(l10n),
                      _buildRequestsList(requests, l10n),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF2D00D))),
              error: (_, __) => _buildError(l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            l10n.myRequests,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.filter_list, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(List<Map<String, dynamic>> requests, AppLocalizations l10n) {
    final activeCount = requests.where((r) => r['status'] != 'completed').length;
    final attentionCount = requests.where((r) => r['status'] == 'awaiting_documents').length;

    return Container(
      padding: const EdgeInsets.all(20),
      transform: Matrix4.translationValues(0, -24, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.active,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        activeCount.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A192F),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+1',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.attention,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    attentionCount.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: l10n.searchIdOrServiceType,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 24),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final requestsAsync = ref.watch(serviceRequestsProvider);
    final requests = requestsAsync.maybeWhen(data: (data) => data, orElse: () => <Map<String, dynamic>>[]);
    
    final allCount = requests.length;
    final pendingCount = requests.where((r) => r['status'] == 'awaiting_form' || r['status'] == 'payment_pending').length;
    final processingCount = requests.where((r) => r['status'] == 'processing' || r['status'] == 'awaiting_documents' || r['status'] == 'submitted').length;
    final completedCount = requests.where((r) => r['status'] == 'completed').length;
    
    final filters = [
      {'label': l10n.all, 'count': allCount},
      {'label': l10n.pending, 'count': pendingCount},
      {'label': l10n.processing, 'count': processingCount},
      {'label': l10n.completed, 'count': completedCount},
    ];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 20, bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == _getFilterKey(index);
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = _getFilterKey(index)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0A192F) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0A192F) : Colors.grey[300]!,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF0A192F).withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ] : null,
                ),
                child: Row(
                  children: [
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF0A192F),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFF0A192F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filter['count']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF0A192F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFilterKey(int index) {
    switch (index) {
      case 0: return 'All';
      case 1: return 'Pending';
      case 2: return 'Processing';
      case 3: return 'Completed';
      default: return 'All';
    }
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> requests, AppLocalizations l10n) {
    final filteredRequests = _filterRequests(requests);
    
    if (filteredRequests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noServiceRequests,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.yourRequestsWillAppearHere,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentActivity,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A192F),
            ),
          ),
          const SizedBox(height: 16),
          ...filteredRequests.map((request) => _buildRequestCard(request, l10n)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterRequests(List<Map<String, dynamic>> requests) {
    var filtered = requests;
    
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((request) {
        final id = request['id']?.toString().toLowerCase() ?? '';
        final serviceName = request['service']?['name']?.toString().toLowerCase() ?? '';
        return id.contains(searchQuery.toLowerCase()) || serviceName.contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    if (selectedFilter == 'All') return filtered;
    
    return filtered.where((request) {
      final status = request['status'] ?? '';
      switch (selectedFilter) {
        case 'Pending':
          return status == 'awaiting_form' || status == 'payment_pending';
        case 'Processing':
          return status == 'processing' || status == 'awaiting_documents' || status == 'submitted';
        case 'Completed':
          return status == 'completed';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildRequestCard(Map<String, dynamic> request, AppLocalizations l10n) {
    final status = request['status'] ?? 'pending';
    final needsAttention = status == 'awaiting_documents' || status == 'rejected';
    
    return GestureDetector(
      onTap: () => context.push('/service-requests/${request['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: needsAttention ? const Color(0xFFEF4444) : const Color(0xFFF2D00D),
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REF: #${request['id']?.toString().toUpperCase().substring(0, 8) ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request['service']?['name'] ?? l10n.serviceRequest,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A192F),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status, l10n),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusTextColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  '${l10n.submittedOn} ${_formatDate(request['createdAt'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (status == 'processing') ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.65,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2D00D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.reviewingDocuments,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Text(
                    '65%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF2D00D),
                    ),
                  ),
                ],
              ),
            ],
            if (needsAttention) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.actionRequired,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  Text(
                    l10n.viewDetails,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF2D00D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFFF2D00D)),
                ],
              ),
            ],
            if (status == 'completed') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.requestCompletedSuccessfully,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.failedToLoadRequests,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A192F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pleaseTryAgain,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.refresh(serviceRequestsProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2D00D),
              foregroundColor: const Color(0xFF0A192F),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.retry, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'awaiting_documents':
      case 'rejected':
        return const Color(0xFFEF4444).withValues(alpha: 0.1);
      case 'processing':
        return const Color(0xFFF2D00D).withValues(alpha: 0.2);
      case 'completed':
        return const Color(0xFF10B981).withValues(alpha: 0.1);
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'awaiting_documents':
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'processing':
        return const Color(0xFF0A192F);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return Colors.grey[700]!;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status) {
      case 'awaiting_documents':
        return l10n.awaitingDocuments;
      case 'awaiting_form':
        return l10n.awaitingForm;
      case 'processing':
        return l10n.processing;
      case 'completed':
        return l10n.completed;
      case 'rejected':
        return l10n.rejected;
      case 'payment_pending':
        return l10n.paymentPending;
      case 'ready_to_submit':
        return l10n.readyToSubmit;
      default:
        return status.toUpperCase().replaceAll('_', ' ');
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
