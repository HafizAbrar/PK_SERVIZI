import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/providers/auth_provider.dart';

class RefreshTokenScreen extends ConsumerStatefulWidget {
  const RefreshTokenScreen({super.key});

  @override
  ConsumerState<RefreshTokenScreen> createState() => _RefreshTokenScreenState();
}

class _RefreshTokenScreenState extends ConsumerState<RefreshTokenScreen> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _refreshToken() async {
    setState(() => _isLoading = true);
    
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }
      
      await ref.read(refreshTokenProvider(refreshToken).future);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token refreshed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refresh failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refresh Token')),
      body: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _refreshToken,
          child: _isLoading 
            ? const CircularProgressIndicator()
            : const Text('Refresh Token'),
        ),
      ),
    );
  }
}