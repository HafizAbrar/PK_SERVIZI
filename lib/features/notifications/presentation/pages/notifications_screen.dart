import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/services/api_service.dart';

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ApiServiceFactory.customer.getMyNotifications();
  final data = response.data as Map<String, dynamic>;
  return List<Map<String, dynamic>>.from(data['data'] ?? []);
});

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(l10n),
          _buildFilterTabs(l10n),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) => _buildNotificationsList(notifications, l10n),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF2D00D))),
              error: (error, stack) => Center(child: Text('${l10n.error}: $error')),
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
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.notifications,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _markAllAsRead(l10n),
            child: Text(
              l10n.markAllAsRead,
              style: const TextStyle(
                color: Color(0xFFF2D00D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          _buildFilterTab(l10n.all, l10n),
          const SizedBox(width: 12),
          _buildFilterTab(l10n.requests, l10n),
          const SizedBox(width: 12),
          _buildFilterTab(l10n.payments, l10n),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter, AppLocalizations l10n) {
    final isSelected = selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          child: Center(
            child: Text(
              filter,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF0A192F),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications, AppLocalizations l10n) {
    final filteredNotifications = _filterNotifications(notifications, l10n);
    
    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 64,
                color: Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noNotifications,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A192F),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) => _buildNotificationItem(filteredNotifications[index], l10n),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, AppLocalizations l10n) {
    final isUnread = !(notification['isRead'] ?? false);
    final type = notification['type'] ?? 'info';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isUnread ? Border.all(color: const Color(0xFFF2D00D), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildNotificationIcon(type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _cleanTitle(notification['title'] ?? ''),
                          style: TextStyle(
                            color: const Color(0xFF0A192F),
                            fontSize: 16,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2D00D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.newLabel,
                            style: const TextStyle(
                              color: Color(0xFF0A192F),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notification['createdAt'], l10n),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color backgroundColor;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'success':
        icon = Icons.check_circle;
        backgroundColor = const Color(0xFF0A192F);
        iconColor = const Color(0xFFF2D00D);
        break;
      case 'warning':
        icon = Icons.warning;
        backgroundColor = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFF59E0B);
        break;
      case 'error':
        icon = Icons.error;
        backgroundColor = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFEF4444);
        break;
      default:
        icon = Icons.notifications;
        backgroundColor = const Color(0xFF0A192F);
        iconColor = const Color(0xFFF2D00D);
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }

  List<Map<String, dynamic>> _filterNotifications(List<Map<String, dynamic>> notifications, AppLocalizations l10n) {
    if (selectedFilter == l10n.all) return notifications;
    
    return notifications.where((notification) {
      final message = notification['message']?.toString().toLowerCase() ?? '';
      if (selectedFilter == l10n.requests) {
        return message.contains('questionnaire') || message.contains('document');
      } else if (selectedFilter == l10n.payments) {
        return message.contains('payment') || message.contains('€');
      }
      return true;
    }).toList();
  }

  String _cleanTitle(String title) {
    return title.replaceAll(RegExp(r'[🎉✅💳📋]'), '').trim();
  }

  String _formatDate(String? dateString, AppLocalizations l10n) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) return l10n.justNow;
      if (difference.inMinutes < 60) return '${difference.inMinutes}${l10n.minutesAgo}';
      if (difference.inHours < 24) return '${difference.inHours}${l10n.hoursAgo}';
      if (difference.inDays == 1) return l10n.yesterday;
      if (difference.inDays < 7) return '${difference.inDays} ${l10n.daysAgo}';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _markAllAsRead(AppLocalizations l10n) async {
    try {
      await ApiServiceFactory.customer.markAllNotificationsAsRead();
      final _ = ref.refresh(notificationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.allNotificationsMarkedAsRead),
            backgroundColor: const Color(0xFF0A192F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}
