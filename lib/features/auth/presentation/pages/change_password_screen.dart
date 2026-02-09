import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordFocusNode = FocusNode();
  bool isButtonEnabled = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_validateFields);
    _newPasswordController.addListener(_validateFields);
    _confirmPasswordController.addListener(_validateFields);
  }
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    super.dispose();
  }
  
  void _validateFields() {
    setState(() {
      isButtonEnabled = _currentPasswordController.text.isNotEmpty && 
                       _newPasswordController.text.isNotEmpty &&
                       _confirmPasswordController.text.isNotEmpty;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthStatePasswordChanged) {
        context.go('/security-success');
      } else if (next is AuthStateError) {
        if (next.message.toLowerCase().contains('current password') || 
            next.message.toLowerCase().contains('incorrect password') ||
            next.message.toLowerCase().contains('password change failed')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.incorrectCurrentPassword)),
          );
          _currentPasswordFocusNode.requestFocus();
        } else {
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
        leading: const BackButton(color: Colors.white),
        title: Text(
          l10n.changePassword,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                  l10n.changePassword,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  l10n.enterCurrentAndNewPassword,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: AppTheme.spacingXLarge),
                _buildField(
                  controller: _currentPasswordController,
                  label: l10n.currentPassword,
                  icon: Icons.lock_outline,
                  obscure: _obscureCurrentPassword,
                  focusNode: _currentPasswordFocusNode,
                  onToggleVisibility: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                _buildField(
                  controller: _newPasswordController,
                  label: l10n.newPassword,
                  icon: Icons.lock_outline,
                  obscure: _obscureNewPassword,
                  onToggleVisibility: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                _buildField(
                  controller: _confirmPasswordController,
                  label: l10n.confirmPassword,
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppTheme.primaryButtonStyle,
                    onPressed: (isButtonEnabled && !isLoading) ? () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authStateProvider.notifier).changePassword(
                          _currentPasswordController.text,
                          _newPasswordController.text,
                        );
                      }
                    } : null,
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
                            l10n.changePassword,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeRegular,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
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
    FocusNode? focusNode,
    VoidCallback? onToggleVisibility,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      focusNode: focusNode,
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
        if (label == l10n.newPassword && v.length < 6) {
          return l10n.passwordMustBe6Chars;
        }
        if (label == l10n.confirmPassword && v != _newPasswordController.text) {
          return l10n.passwordsDoNotMatch;
        }
        return null;
      },
    );
  }
}
