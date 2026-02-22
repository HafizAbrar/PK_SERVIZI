import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: profileAsync.when(
        data: (profile) => RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () async => ref.invalidate(profileProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: false,
                backgroundColor: AppTheme.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildAvatar(profile),
                          const SizedBox(height: 16),
                          Text(
                            profile['fullName'] ?? l10n.user,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile['email'] ?? l10n.defaultEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () async {
                      await context.push('/profile/edit');
                      ref.invalidate(profileProvider);
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: AppTheme.cardDecoration.copyWith(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: _buildProfileContent(profile),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () async => ref.invalidate(profileProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(child: Text(l10n.failedToLoad)),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> profile) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: (profile['profile']?['avatarUrl'] != null && profile['profile']['avatarUrl'].toString().isNotEmpty)
            ? ClipOval(
                child: Image.network(
                  profile['profile']['avatarUrl'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return ClipOval(
                      child: Image.asset(
                        'assets/logos/APP LOGO.jpeg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CircularProgressIndicator(color: AppTheme.primaryColor);
                  },
                ),
              )
            : ClipOval(
                child: Image.asset(
                  'assets/logos/APP LOGO.jpeg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> profile) {
    return Column(
      children: [
        const SizedBox(height: AppTheme.spacingMedium),
        _buildProfileOptions(),
      ],
    );
  }

  Widget _buildProfileOptions() {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      {'title': l10n.editProfile, 'icon': Icons.edit_outlined, 'route': '/profile/edit'},
      {'title': l10n.changePassword, 'icon': Icons.lock_outline, 'route': '/profile/change-password'},
      {'title': l10n.mySubscriptions, 'icon': Icons.subscriptions_outlined, 'route': '/subscription'},
      {'title': l10n.invoices, 'icon': Icons.receipt_long_outlined, 'route': '/invoices'},
      {'title': l10n.settings, 'icon': Icons.settings_outlined, 'route': '/settings'},
    ];

    return Column(
      children: [
        ...options.map((option) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(option['icon'] as IconData, color: AppTheme.primaryColor, size: 20),
            ),
            title: Text(
              option['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.textTertiary, size: 16),
            onTap: () => context.push(option['route'] as String),
          ),
        )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
            onTap: _handleLogout,
          ),
        ),
      ],
    );
  }

  void _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.doYouWantToExit),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }
}
