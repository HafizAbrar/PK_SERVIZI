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
      backgroundColor: const Color(0xFFF6F7F8),
      body: Column(
        children: [
          _buildHeader(l10n),
          _buildFilterTabs(l10n),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) => _buildNotificationsList(notifications, l10n),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF186ADC))),
              error: (error, stack) => Center(child: Text('${l10n.error}: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: const Icon(Icons.arrow_back_ios, size: 24, color: Color(0xFF111418)),
          ),
          Text(
            l10n.notifications,
            style: const TextStyle(
              color: Color(0xFF111418),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => _markAllAsRead(l10n),
            child: Text(
              l10n.markAllAsRead,
              style: const TextStyle(
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

  Widget _buildFilterTabs(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildFilterTab(l10n.all, l10n),
            _buildFilterTab(l10n.requests, l10n),
            _buildFilterTab(l10n.payments, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String filter, AppLocalizations l10n) {
    final isSelected = selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = filter),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)] : null,
          ),
          child: Center(
            child: Text(
              filter,
              style: TextStyle(
                color: isSelected ? const Color(0xFF111418) : const Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
            const Icon(Icons.notifications_none, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(l10n.noNotifications, style: const TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) => _buildNotificationItem(filteredNotifications[index], l10n),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, AppLocalizations l10n) {
    final isUnread = !(notification['isRead'] ?? false);
    final type = notification['type'] ?? 'info';
    
    return Container(
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF186ADC).withValues(alpha: 0.05) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Stack(
        children: [
          if (isUnread)
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF186ADC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildNotificationIcon(type),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _cleanTitle(notification['title'] ?? ''),
                              style: TextStyle(
                                color: const Color(0xFF111418),
                                fontSize: 16,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF186ADC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.newLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF637288),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification['createdAt'], l10n),
                        style: const TextStyle(
                          color: Color(0xFF637288),
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
        ],
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
        backgroundColor = const Color(0xFF186ADC);
        iconColor = Colors.white;
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
        icon = Icons.info;
        backgroundColor = const Color(0xFF186ADC).withValues(alpha: 0.1);
        iconColor = const Color(0xFF186ADC);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 24),
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
          SnackBar(content: Text(l10n.allNotificationsMarkedAsRead)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }
}
