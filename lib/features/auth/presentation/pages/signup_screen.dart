import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool isButtonEnabled = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
    _passwordController.addListener(_validate);
    _fullNameController.addListener(_validate);
    _phoneController.addListener(_validate);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty &&
                       _passwordController.text.isNotEmpty &&
                       _fullNameController.text.isNotEmpty &&
                       _phoneController.text.isNotEmpty;
    });
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authStateProvider.notifier).register(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthStateRegisterSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountCreated)),
        );
        context.go('/login');
      } else if (next is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthStateLoading;
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          l10n.createAccount,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                  l10n.welcomeToPKServizi,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  l10n.createAccountToContinue,
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
                          color: Colors.black.withValues(alpha: 0.3),
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
                              colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
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
                    Container(height: 1, width: 24, color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                    const SizedBox(width: 12),
                    Text(
                      l10n.excellenceInFiscalCare,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Color(0xFF996515),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(height: 1, width: 24, color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXLarge),
                _buildField(
                  controller: _fullNameController,
                  label: l10n.fullName,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                _buildField(
                  controller: _phoneController,
                  label: l10n.phone,
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                _buildField(
                  controller: _emailController,
                  label: l10n.email,
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                _buildField(
                  controller: _passwordController,
                  label: l10n.password,
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppTheme.primaryButtonStyle,
                    onPressed: isButtonEnabled && !isLoading ? _registerUser : null,
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
                            l10n.signUp,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeRegular,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.alreadyHaveAccount),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        l10n.signIn,
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
    final l10n = AppLocalizations.of(context)!;
    
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
        if (v!.isEmpty) return l10n.requiredField;
        if (label == l10n.email && !v.contains('@')) {
          return l10n.enterValidEmail;
        }
        if (label == l10n.password && v.length < 6) {
          return l10n.passwordMinLength;
        }
        return null;
      },
    );
  }
}
