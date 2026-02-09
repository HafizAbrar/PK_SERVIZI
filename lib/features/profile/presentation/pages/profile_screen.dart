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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.profile,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              await context.push('/profile/edit');
              ref.invalidate(profileProvider);
            },
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: profileAsync.when(
          data: (profile) => RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async => ref.invalidate(profileProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: _buildProfileContent(profile),
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
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> profile) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: AppTheme.spacingMedium),
        CircleAvatar(
          radius: 60,
          backgroundColor: AppTheme.primaryColor,
          child: (profile['profile']?['avatarUrl'] != null && profile['profile']['avatarUrl'].toString().isNotEmpty)
              ? ClipOval(
                  child: Image.network(
                    profile['profile']['avatarUrl'],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 60, color: Colors.white);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator(color: Colors.white);
                    },
                  ),
                )
              : const Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Text(
          profile['fullName'] ?? l10n.user,
          style: TextStyle(
            fontSize: AppTheme.fontSizeXXLarge,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          profile['email'] ?? l10n.defaultEmail,
          style: TextStyle(
            fontSize: AppTheme.fontSizeRegular,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXLarge),
        _buildProfileOptions(),
      ],
    );
  }

  Widget _buildProfileOptions() {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      {'title': l10n.editProfile, 'icon': Icons.edit, 'route': '/profile/edit'},
      {'title': l10n.myAppointments, 'icon': Icons.calendar_today, 'route': '/appointments'},
      {'title': l10n.changePassword, 'icon': Icons.lock, 'route': '/profile/change-password'},
      {'title': l10n.mySubscriptions, 'icon': Icons.subscriptions, 'route': '/subscription'},
      {'title': l10n.settings, 'icon': Icons.settings, 'route': '/settings'},
    ];

    return Column(
      children: [
        ...options.map((option) => Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
          child: ListTile(
            leading: Icon(option['icon'] as IconData, color: AppTheme.primaryColor),
            title: Text(option['title'] as String),
            trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary),
            onTap: () => context.push(option['route'] as String),
          ),
        )),
        Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
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
