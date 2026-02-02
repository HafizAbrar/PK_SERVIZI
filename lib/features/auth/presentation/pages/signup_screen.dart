import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fiscalCodeController = TextEditingController();

  bool gdprConsent = false;
  bool marketingConsent = false;
  bool isButtonEnabled = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
    _passwordController.addListener(_validate);
    _firstNameController.addListener(_validate);
    _lastNameController.addListener(_validate);
    _fiscalCodeController.addListener(_validate);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fiscalCodeController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty &&
                       _passwordController.text.isNotEmpty &&
                       _firstNameController.text.isNotEmpty &&
                       _lastNameController.text.isNotEmpty &&
                       _fiscalCodeController.text.isNotEmpty &&
                       gdprConsent;
    });
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authStateProvider.notifier).register(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      fiscalCode: _fiscalCodeController.text,
      phone: '',
      dateOfBirth: '',
      address: '',
      city: '',
      postalCode: '',
      province: '',
      gdprConsent: gdprConsent,
      marketingConsent: marketingConsent,
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
        context.go('/profile-completion');
      } else if (next is AuthStateError) {
        String errorMessage = next.message;
        if (errorMessage.contains('Default customer role not found')) {
          errorMessage = 'Backend configuration error. Please contact support.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    });

    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthStateLoading;
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          l10n.createAccount,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  l10n.welcomeToPKServizi,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.createAccountToContinue,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 25),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logos/LOGO 1 pk_services.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildField(
                  controller: _firstNameController,
                  label: l10n.firstName,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _lastNameController,
                  label: l10n.lastName,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _fiscalCodeController,
                  label: l10n.fiscalCode,
                  icon: Icons.credit_card,
                  maxLength: 16,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _emailController,
                  label: l10n.email,
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _passwordController,
                  label: l10n.password,
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: gdprConsent,
                      activeColor: const Color(0xFF1B5E20),
                      onChanged: (v) {
                        setState(() {
                          gdprConsent = v!;
                          _validate();
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(text: '${l10n.agreeToPrivacyPolicy} '),
                            TextSpan(
                              text: l10n.required,
                              style: const TextStyle(
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: marketingConsent,
                      activeColor: const Color(0xFF1B5E20),
                      onChanged: (v) {
                        setState(() {
                          marketingConsent = v!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        l10n.agreeToMarketing,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.alreadyHaveAccount),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: Text(
                        l10n.signIn,
                        style: const TextStyle(color: Color(0xFF1B5E20)),
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
    int? maxLength,
    String? hint,
    VoidCallback? onToggleVisibility,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      maxLength: maxLength,
      textCapitalization: label == l10n.fiscalCode ? TextCapitalization.characters : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1B5E20)),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF1B5E20),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1B5E20)),
        ),
      ),
      validator: (v) {
        if (v!.isEmpty) return l10n.requiredField;
        if (label == l10n.email && !v.contains('@')) {
          return l10n.enterValidEmail;
        }
        if (label == l10n.fiscalCode) {
          if (v.length != 16) return l10n.fiscalCodeLength;
          if (!RegExp(r'^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$').hasMatch(v.toUpperCase())) {
            return l10n.invalidFiscalCode;
          }
        }
        if (label == l10n.password && v.length < 6) {
          return l10n.passwordMinLength;
        }
        return null;
      },
    );
  }
}
