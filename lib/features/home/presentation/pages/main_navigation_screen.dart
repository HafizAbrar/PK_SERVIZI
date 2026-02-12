import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../services/presentation/pages/services_screen.dart';
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
      const ServicesScreen(),
      const ServiceRequestsScreen(),
      const SubscriptionPlansScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
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
            color: Colors.white,
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
          Icon(icon, color: isActive ? const Color(0xFFF2D00D) : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isActive ? const Color(0xFFF2D00D) : Colors.grey,
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
        color: const Color(0xFF0A192F),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC5A059), Color(0xFF0A192F)],
                ),
              ),
              child: profileAsync.when(
                data: (profile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF112240),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
                      ),
                      child: profile['profile']?['avatarUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                profile['profile']['avatarUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: Color(0xFFC5A059), size: 36),
                              ),
                            )
                          : const Icon(Icons.shield, color: Color(0xFFC5A059), size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile['fullName'] ?? l10n.menu,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      profile['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE2C275),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF112240),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.shield, color: Color(0xFFC5A059), size: 36),
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF112240),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.shield, color: Color(0xFFC5A059), size: 36),
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
            const Divider(color: Color(0xFFC5A059), thickness: 0.5),
            _buildDrawerAction(context, Icons.folder, l10n.documents, () {
              Navigator.pop(context);
              context.go('/documents');
            }),
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
      leading: Icon(icon, color: isSelected ? const Color(0xFFC5A059) : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFFC5A059) : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF112240),
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
