import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/biometric_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static const _storage = FlutterSecureStorage();
  final _biometricService = BiometricService();

  bool isButtonEnabled = false;
  bool _obscurePassword = true;
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
    _passwordController.addListener(_validate);
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final canUse = await _biometricService.canUseBiometric();
    
    if (mounted) {
      setState(() {
        _showBiometric = true; // Always show for testing
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty && 
                       _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    await _storage.write(key: 'saved_email', value: _emailController.text);
    await _storage.write(key: 'saved_password', value: _passwordController.text);

    await ref.read(authStateProvider.notifier).login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _biometricLogin() async {
    // Check if user has saved credentials
    final credentials = await _biometricService.getSavedCredentials();
    
    if (credentials == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login or signup by credentials')),
        );
      }
      return;
    }
    
    // Activate fingerprint scanner
    final authenticated = await _biometricService.authenticate();
    
    if (authenticated) {
      await ref.read(authStateProvider.notifier).login(
        email: credentials['email']!,
        password: credentials['password']!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthStateLoginSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccessful)),
          );
          context.go('/home');
        }
      } else if (next is AuthStateError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.message)),
          );
        }
      }
    });

    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthStateLoading;
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Sign In',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  'Sign in to continue',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: AppTheme.spacingXLarge),
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0A1D37), Color(0xFF1E3A5F)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFF996515)],
                            ).createShader(bounds),
                            child: const Text(
                              'PK',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text(
                      'PK SERVIZI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 6,
                        color: Color(0xFF0A1D37),
                      ),
                                     ),
                   ],
                 ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 1, width: 24, color: const Color(0xFFD4AF37).withOpacity(0.5)),
                    const SizedBox(width: 12),
                    const Text(
                      'EXCELLENCE IN FISCAL CARE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Color(0xFF996515),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(height: 1, width: 24, color: const Color(0xFFD4AF37).withOpacity(0.5)),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXLarge),
                _buildField(
                  controller: _emailController,
                  label: AppLocalizations.of(context)!.email,
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                _buildField(
                  controller: _passwordController,
                  label: AppLocalizations.of(context)!.password,
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword,
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppTheme.primaryButtonStyle,
                    onPressed: isButtonEnabled && !isLoading ? _signIn : null,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.signIn,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeRegular,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Center(
                  child: IconButton(
                    onPressed: _biometricLogin,
                    icon: const Icon(Icons.fingerprint, size: 48),
                    color: AppTheme.primaryColor,
                    tooltip: 'Login with fingerprint',
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    VoidCallback? onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: AppTheme.inputDecoration(label).copyWith(
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.primaryColor,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      validator: (v) {
        if (v!.isEmpty) return AppLocalizations.of(context)!.requiredField;
        if (label == AppLocalizations.of(context)!.email && !v.contains('@')) {
          return AppLocalizations.of(context)!.enterValidEmail;
        }
        return null;
      },
    );
  }
}