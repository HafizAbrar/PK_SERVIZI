import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
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
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          data: (profile) => _buildProfileContent(profile),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading profile')),
        ),
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor,
            child: (profile['avatar'] != null && profile['avatar'].toString().isNotEmpty)
                ? ClipOval(
                    child: Image.network(
                      profile['avatar'],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // print('Avatar load error: $error');
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
            profile['fullName'] ?? 'User Name',
            style: TextStyle(
              fontSize: AppTheme.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            profile['email'] ?? 'user@email.com',
            style: TextStyle(
              fontSize: AppTheme.fontSizeRegular,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXLarge),
          _buildProfileOptions(),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    final options = [
      {'title': 'Edit Profile', 'icon': Icons.edit, 'route': '/profile/edit'},
      {'title': 'My Appointments', 'icon': Icons.calendar_today, 'route': '/appointments'},
      {'title': 'Change Password', 'icon': Icons.lock, 'route': '/profile/change-password'},
      {'title': 'My Subscriptions', 'icon': Icons.subscriptions, 'route': '/subscription'},
      {'title': 'Settings', 'icon': Icons.settings, 'route': '/settings'},
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
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
            onTap: _handleLogout,
          ),
        ),
      ],
    );
  }

  void _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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