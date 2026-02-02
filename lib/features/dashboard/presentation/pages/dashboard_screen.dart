import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? profile;
  List<dynamic> recentAppointments = [];
  List<dynamic> serviceRequests = [];
  int unreadNotifications = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final futures = await Future.wait([
        ApiServiceFactory.customer.getProfile(),
        ApiServiceFactory.customer.getMyAppointments(),
        ApiServiceFactory.customer.getMyServiceRequests(),
        ApiServiceFactory.customer.getUnreadCount(),
      ]);

      setState(() {
        profile = futures[0].data;
        recentAppointments = (futures[1].data as List? ?? []).take(3).toList();
        serviceRequests = (futures[2].data as List? ?? []).take(3).toList();
        unreadNotifications = futures[3].data?['count'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              profile?['name'] ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => context.push('/notifications'),
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppTheme.errorColor,
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          _buildQuickActions(),
          const SizedBox(height: AppTheme.spacingXLarge),
          _buildSection('Recent Appointments', recentAppointments, '/appointments'),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildSection('Service Requests', serviceRequests, '/service-requests'),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Book Appointment', 'icon': Icons.calendar_today, 'route': '/book-appointment', 'color': AppTheme.primaryColor},
      {'title': 'Service Request', 'icon': Icons.request_page, 'route': '/create-service-request', 'color': AppTheme.secondaryColor},
      {'title': 'Documents', 'icon': Icons.folder, 'route': '/documents', 'color': AppTheme.accentColor},
      {'title': 'Payments', 'icon': Icons.payment, 'route': '/payments', 'color': AppTheme.successColor},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: AppTheme.fontSizeXLarge,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.spacingMedium,
            mainAxisSpacing: AppTheme.spacingMedium,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              child: InkWell(
                onTap: () => context.push(action['route'] as String),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        size: 40,
                        color: action['color'] as Color,
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        action['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<dynamic> items, String route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: AppTheme.fontSizeXLarge,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () => context.push(route),
              child: Text('View All', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        items.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Center(
                    child: Text(
                      'No ${title.toLowerCase()} yet',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              )
            : Column(
                children: items.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(
                        title.contains('Appointment') ? Icons.event : Icons.request_page,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(item['title'] ?? 'Item'),
                    subtitle: Text(item['date'] ?? item['status'] ?? 'No details'),
                    trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary),
                    onTap: () => context.push('$route/${item['id']}'),
                  ),
                )).toList(),
              ),
      ],
    );
  }
}