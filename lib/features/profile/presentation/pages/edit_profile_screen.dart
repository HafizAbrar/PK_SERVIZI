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

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fiscalCodeController = TextEditingController();
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
    _nameController.dispose();
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
        _nameController.text = profile?['fullName'] ?? '';
        _emailController.text = profile?['email'] ?? '';
        _phoneController.text = profile?['phone'] ?? '';
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
      
      final profileData = {
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'fiscalCode': _fiscalCodeController.text,
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
        
        if (e is DioException && e.response?.statusCode == 400) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData['message'] != null) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = l10n.invalidDataPleasecheckYourInputs;
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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
                                    ? ClipOval(
                                        child: Image.asset(
                                          'assets/logos/APP LOGO.jpeg',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
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
                        controller: _nameController,
                        label: l10n.fullName,
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
                      _buildField(
                        controller: _phoneController,
                        label: l10n.phoneNumber,
                        icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                      ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: AppTheme.inputDecoration(label).copyWith(
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      ),
      validator: (v) {
        if (v!.isEmpty) return l10n.thisFieldIsRequired;
        if (label == l10n.email && !v.contains('@')) {
          return l10n.enterAValidEmail;
        }
        return null;
      },
    );
  }
}
