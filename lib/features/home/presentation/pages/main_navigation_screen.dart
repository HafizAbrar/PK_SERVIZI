import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../services/presentation/pages/service_type_screen.dart';
import '../../../requests/presentation/pages/service_requests_screen.dart';
import '../../../subscriptions/presentation/pages/subscription_plans_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'home_screen.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const HomeScreen(),
      const ServiceTypeScreen(),
      const ServiceRequestsScreen(),
      const SubscriptionPlansScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop();
          return;
        }
        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        drawer: _buildDrawer(context, ref),
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, ref, Icons.home, l10n.home, 0),
              _buildNavItem(context, ref, Icons.grid_view, l10n.services, 1),
              _buildNavItem(context, ref, Icons.assignment, l10n.requests, 2),
              _buildNavItem(context, ref, Icons.subscriptions, l10n.plans, 3),
              _buildNavItem(context, ref, Icons.account_circle, l10n.profile, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, IconData icon, String label, int index) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => ref.read(navigationIndexProvider.notifier).state = index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppTheme.accentColor : Colors.white70, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isActive ? AppTheme.accentColor : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Drawer(
      child: Container(
        color: AppTheme.primaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: profileAsync.when(
                data: (profile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: profile['profile']?['avatarUrl'] != null
                          ? Image.network(
                              profile['profile']['avatarUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/logos/APP LOGO.jpeg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/logos/APP LOGO.jpeg',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile['fullName'] ?? l10n.menu,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      profile['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logos/APP LOGO.jpeg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.menu,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                error: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/logos/APP LOGO.jpeg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.menu,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(context, ref, Icons.home, l10n.home, 0),
            _buildDrawerItem(context, ref, Icons.business, l10n.services, 1),
            _buildDrawerItem(context, ref, Icons.assignment, l10n.requests, 2),
            _buildDrawerItem(context, ref, Icons.subscriptions, l10n.plans, 3),
            _buildDrawerItem(context, ref, Icons.person, l10n.profile, 4),
            const Divider(color: AppTheme.goldLight, thickness: 0.5),
            _buildDrawerAction(context, Icons.receipt_long, l10n.invoices, () {
              Navigator.pop(context);
              context.go('/invoices');
            }),
            _buildDrawerAction(context, Icons.notifications, l10n.notifications, () {
              Navigator.pop(context);
              context.go('/notifications');
            }),
            _buildDrawerAction(context, Icons.settings, l10n.settings, () {
              Navigator.pop(context);
              context.go('/settings');
            }),
            _buildDrawerAction(context, Icons.logout, l10n.logout, () {
              Navigator.pop(context);
              context.go('/login');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, WidgetRef ref, IconData icon, String title, int index) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isSelected = currentIndex == index;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.accentColor : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.accentColor : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.accentColor,
      onTap: () {
        ref.read(navigationIndexProvider.notifier).state = index;
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDrawerAction(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70),
      ),
      onTap: onTap,
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitApp),
        content: Text(l10n.doYouWantToExit),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.exit),
          ),
        ],
      ),
    ) ?? false;
  }
}
