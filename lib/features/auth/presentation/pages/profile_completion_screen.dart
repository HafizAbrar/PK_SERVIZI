import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends ConsumerState<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _provinceController = TextEditingController();
  final _fiscalCodeController = TextEditingController();
  final _idCardController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  
  bool gdprConsent = false;
  bool marketingConsent = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.completeYourProfile,
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
                const SizedBox(height: 20),
                Text(
                  l10n.personalInformation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _birthDateController,
                  label: l10n.birthDate,
                  icon: Icons.calendar_today,
                  hint: 'YYYY-MM-DD',
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _addressController,
                  label: l10n.address,
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _cityController,
                        label: l10n.city,
                        icon: Icons.location_city,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        controller: _postalCodeController,
                        label: l10n.postalCode,
                        icon: Icons.mail,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _provinceController,
                  label: l10n.province,
                  icon: Icons.map,
                ),
                const SizedBox(height: 30),
                Text(
                  l10n.identityDocuments,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _fiscalCodeController,
                  label: l10n.fiscalCode,
                  icon: Icons.badge,
                  hint: 'RSSMRA85M01H501Z',
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _idCardController,
                  label: l10n.idCardNumber,
                  icon: Icons.credit_card,
                ),
                const SizedBox(height: 30),
                Text(
                  l10n.emergencyContact,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _emergencyContactController,
                  label: l10n.emergencyContactName,
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _emergencyPhoneController,
                  label: l10n.emergencyContactPhone,
                  icon: Icons.phone,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 30),
                Text(
                  l10n.consent,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: gdprConsent,
                  onChanged: (value) => setState(() => gdprConsent = value!),
                  title: Text(l10n.agreeToGDPR),
                  activeColor: const Color(0xFF1B5E20),
                ),
                CheckboxListTile(
                  value: marketingConsent,
                  onChanged: (value) => setState(() => marketingConsent = value!),
                  title: Text(l10n.agreeToMarketing),
                  activeColor: const Color(0xFF1B5E20),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: gdprConsent ? _completeProfile : null,
                    child: Text(
                      l10n.completeProfile,
                      style: const TextStyle(
                        fontSize: 16,
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
    String? hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1B5E20)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B5E20)),
        ),
      ),
      validator: (v) => v!.isEmpty ? l10n.requiredField : null,
    );
  }

  void _completeProfile() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_formKey.currentState!.validate()) {
      // Simulate profile completion
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileCompletedSuccessfully)),
        );
        context.go('/home');
      }
    }
  }
}