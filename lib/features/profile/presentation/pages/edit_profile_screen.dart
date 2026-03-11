import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../providers/profile_provider.dart';
import '../widgets/country_code_picker_dialog.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fiscalCodeController = TextEditingController();
  String _selectedCountryCode = '+39';
  File? _selectedImage;
  bool isLoading = false;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fiscalCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;
    
    try {
      final apiClient = ref.read(apiClientProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_selectedImage!.path),
      });
      
      await apiClient.post('/api/v1/users/avatar', data: formData);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorUploadingAvatar}: $e')),
        );
      }
    }
  }

  Future<void> _loadProfile() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/api/v1/users/profile');
      final profile = response.data;
      
      setState(() {
        final fullName = profile?['fullName'] ?? '';
        final nameParts = fullName.split(' ');
        _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
        _surnameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        _emailController.text = profile?['email'] ?? '';
        final phone = profile?['phone'] ?? '';
        if (phone.startsWith('+')) {
          final parts = phone.split(' ');
          if (parts.isNotEmpty) {
            _selectedCountryCode = parts[0];
            _phoneController.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
          }
        } else {
          _phoneController.text = phone;
        }
        _fiscalCodeController.text = profile?['fiscalCode'] ?? '';
        isLoadingProfile = false;
      });
    } catch (e) {
      setState(() => isLoadingProfile = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingProfile}: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Upload avatar first if selected
      if (_selectedImage != null) {
        await _uploadAvatar();
      }
      
      final phone = _phoneController.text.trim();
      final profileData = {
        'fullName': '${_firstNameController.text.trim()} ${_surnameController.text.trim()}'.trim(),
        'email': _emailController.text.trim(),
        'phone': phone.isNotEmpty ? '$_selectedCountryCode$phone' : '',
        'fiscalCode': _fiscalCodeController.text.trim().toUpperCase(),
      };

      final apiClient = ref.read(apiClientProvider);
      await apiClient.put('/api/v1/users/profile', data: profileData);
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ref.invalidate(profileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdatedSuccessfully)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        String errorMessage = l10n.errorUpdatingProfile;
        
        if (e is DioException) {
          if (e.response?.statusCode == 400) {
            final responseData = e.response?.data;
            if (responseData is Map && responseData['message'] != null) {
              errorMessage = responseData['message'];
            } else if (responseData is Map && responseData['errors'] != null) {
              errorMessage = responseData['errors'].toString();
            } else {
              errorMessage = l10n.invalidDataPleasecheckYourInputs;
            }
          }
          print('Error updating profile: ${e.response?.data}');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.editProfile,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        l10n.updateYourProfile,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: AppTheme.fontSizeXXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXSmall),
                      Text(
                        l10n.keepYourInformationUpToDate,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: AppTheme.spacingXLarge),
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: AppTheme.primaryColor,
                                backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                                child: _selectedImage == null 
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.accentColor,
                                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXLarge),
                      _buildField(
                        controller: _firstNameController,
                        label: l10n.firstName,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildField(
                        controller: _surnameController,
                        label: l10n.surname,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildField(
                        controller: _emailController,
                        label: l10n.email,
                        icon: Icons.email_outlined,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildPhoneField(),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildField(
                        controller: _fiscalCodeController,
                        label: l10n.fiscalCode,
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: AppTheme.spacingXLarge),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppTheme.primaryButtonStyle,
                          onPressed: isLoading ? null : _updateProfile,
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
                                  l10n.updateProfile,
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

  Widget _buildPhoneField() {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showCountryCodePicker(),
          child: Container(
            width: 110,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCountryCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildField(
            controller: _phoneController,
            label: l10n.phoneNumber,
            icon: Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
        ),
      ],
    );
  }

  void _showCountryCodePicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryCodePickerDialog(
        selectedCode: _selectedCountryCode,
        onSelect: (code) {
          setState(() => _selectedCountryCode = code);
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      textCapitalization: label == l10n.fiscalCode ? TextCapitalization.characters : TextCapitalization.none,
      decoration: AppTheme.inputDecoration(label).copyWith(
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        helperText: label == l10n.fiscalCode ? '16 characters' : null,
      ),
      validator: (v) {
        if (isRequired && (v == null || v.trim().isEmpty)) {
          return l10n.thisFieldIsRequired;
        }
        if (label == l10n.email && v != null && v.isNotEmpty && !v.contains('@')) {
          return l10n.enterAValidEmail;
        }
        if (label == l10n.fiscalCode && v != null && v.isNotEmpty) {
          final fiscalCode = v.trim().toUpperCase();
          if (fiscalCode.length != 16) {
            return 'Fiscal code must be exactly 16 characters';
          }
          if (!RegExp(r'^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$').hasMatch(fiscalCode)) {
            return 'Invalid fiscal code format';
          }
        }
        return null;
      },
    );
  }
}
