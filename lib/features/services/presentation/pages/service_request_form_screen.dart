import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../data/models/service.dart' as service_models;

final serviceFormProvider = FutureProvider.family<service_models.FormSchema, String>((ref, serviceId) async {
  debugPrint('Loading form schema for serviceId: $serviceId');
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/services/$serviceId/schema');
  debugPrint('Form schema response: ${response.data}');
  return service_models.FormSchema.fromJson(response.data['data']);
});

class ServiceRequestFormScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String? serviceRequestId;
  
  const ServiceRequestFormScreen({
    super.key, 
    required this.serviceId,
    this.serviceRequestId,
  });

  @override
  ConsumerState<ServiceRequestFormScreen> createState() => _ServiceRequestFormScreenState();
}

class _ServiceRequestFormScreenState extends ConsumerState<ServiceRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formValues = {};
  final Map<String, List<PlatformFile>> _uploadedFiles = {};
  int _currentStep = 0;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schemaAsync = ref.watch(serviceFormProvider(widget.serviceId));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: schemaAsync.when(
        data: (schema) => _buildForm(schema),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF2D00D))),
        error: (error, stackTrace) {
          debugPrint('Error loading form schema: $error');
          return _buildError(error.toString());
        },
      ),
    );
  }

  Widget _buildForm(service_models.FormSchema schema) {
    final sections = schema.sections;
    final currentSection = sections[_currentStep];
    
    return Column(
      children: [
        _buildAppBar(),
        _buildProgressBar(sections.length),
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(currentSection),
                  _buildFormFields(currentSection),
                  if (_currentStep == 0) _buildInfoCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
        _buildBottomActions(sections.length),
      ],
    );
  }

  Widget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          ),
          Expanded(
            child: Text(
              l10n.serviceRequest,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int totalSteps) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      transform: Matrix4.translationValues(0, -12, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.step} ${_currentStep + 1}: ${_getSectionTitle(_currentStep)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                ),
                Text(
                  '${_currentStep + 1} ${l10n.ofText} $totalSteps',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_currentStep + 1) / totalSteps,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2D00D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(service_models.FormSection section) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pleaseEnsureDataMatches,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(service_models.FormSection section) {
    return Column(
      children: section.fields.map((field) => _buildFormField(field)).toList(),
    );
  }

  Widget _buildFormField(service_models.FormField field) {
    if (field.type == 'hidden') return const SizedBox.shrink();
    
    _controllers[field.name] ??= TextEditingController();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.type != 'checkbox')
            Text(
              '${field.label}${field.required ? ' *' : ''}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
            ),
          const SizedBox(height: 8),
          _buildFieldWidget(field),
        ],
      ),
    );
  }

  Widget _buildFieldWidget(service_models.FormField field) {
    switch (field.type) {
      case 'select':
        return _buildDropdownField(field);
      case 'date':
        return _buildDateField(field);
      case 'time':
        return _buildTimeField(field);
      case 'datetime':
        return _buildDateTimeField(field);
      case 'textarea':
        return _buildTextAreaField(field);
      case 'checkbox':
        return _buildCheckboxField(field);
      case 'radio':
        return _buildRadioField(field);
      case 'file':
        return _buildFileField(field);
      case 'range':
        return _buildRangeField(field);
      case 'color':
        return _buildColorField(field);
      case 'email':
      case 'phone':
      case 'url':
      case 'password':
      case 'number':
      case 'text':
      default:
        return _buildTextFormField(field);
    }
  }

  Widget _buildTextFormField(service_models.FormField field) {
    return TextFormField(
      controller: _controllers[field.name],
      keyboardType: _getKeyboardType(field.type),
      obscureText: field.type == 'password',
      inputFormatters: _getInputFormatters(field.type),
      decoration: InputDecoration(
        hintText: _getFieldHint(field),
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: field.type == 'password' ? const Icon(Icons.visibility_off) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF2D00D), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildTextAreaField(service_models.FormField field) {
    return TextFormField(
      controller: _controllers[field.name],
      maxLines: 4,
      decoration: InputDecoration(
        hintText: _getFieldHint(field),
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF2D00D), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildCheckboxField(service_models.FormField field) {
    return CheckboxListTile(
      title: Text('${field.label}${field.required ? ' *' : ''}'),
      value: _formValues[field.name] ?? false,
      onChanged: (value) => setState(() => _formValues[field.name] = value),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildRadioField(service_models.FormField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.required)
          Text(
            '${field.label} *',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111418)),
          ),
        ...field.options?.map((option) => RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: _formValues[field.name],
          onChanged: (value) => setState(() => _formValues[field.name] = value),
          contentPadding: EdgeInsets.zero,
        )).toList() ?? [],
      ],
    );
  }

  Widget _buildFileField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    final files = _uploadedFiles[field.name] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pickFile(field.name),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[100]!),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A192F).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.upload_file, color: Color(0xFFF2D00D), size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  files.isEmpty ? l10n.chooseFile : '${files.length} ${l10n.filesSelected}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                ),
              ],
            ),
          ),
        ),
        if (files.isNotEmpty) ...
          files.map((file) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.attach_file, size: 16, color: Color(0xFFF2D00D)),
                Expanded(child: Text(file.name, style: const TextStyle(fontSize: 12))),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => _removeFile(field.name, file),
                ),
              ],
            ),
          )),
      ],
    );
  }

  Widget _buildTimeField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _controllers[field.name],
      readOnly: true,
      decoration: InputDecoration(
        hintText: l10n.selectTime,
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: const Icon(Icons.access_time, color: Color(0xFFF2D00D)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF2D00D), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null && mounted) {
          _controllers[field.name]!.text = time.format(context);
        }
      },
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildDateTimeField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _controllers[field.name],
      readOnly: true,
      decoration: InputDecoration(
        hintText: l10n.selectDateAndTime,
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: const Icon(Icons.event, color: Color(0xFFF2D00D)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF2D00D), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null && mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null && mounted) {
            final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            _controllers[field.name]!.text = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${time.format(context)}';
          }
        }
      },
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildRangeField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    final value = _formValues[field.name] ?? 0.0;
    return Column(
      children: [
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          label: value.round().toString(),
          onChanged: (newValue) => setState(() => _formValues[field.name] = newValue),
        ),
        Text('${l10n.value}: ${value.round()}'),
      ],
    );
  }

  Widget _buildColorField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    final color = _formValues[field.name] ?? Colors.blue;
    return GestureDetector(
      onTap: () => _showColorPicker(field.name),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: const Color(0xFFDCE0E5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(l10n.tapToSelectColor, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(service_models.FormField field) {
    return DropdownButtonFormField<String>(
      value: _formValues[field.name],
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF2D00D), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
      items: field.options?.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: (value) => setState(() => _formValues[field.name] = value),
      validator: (value) => _validateField(field, value?.toString()),
    );
  }

  Widget _buildDateField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _controllers[field.name],
      readOnly: true,
      decoration: InputDecoration(
        hintText: l10n.selectDate,
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFF2D00D)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF2D00D), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null && mounted) {
          _controllers[field.name]!.text = '${date.day}/${date.month}/${date.year}';
        }
      },
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildInfoCard() {
    if (_currentStep != 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2D00D).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2D00D).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info, color: Color(0xFF0A192F), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nextSteps,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.inStep2YoullBeAsked,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(int totalSteps) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _nextStep(totalSteps),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF2D00D),
            foregroundColor: const Color(0xFF0A192F),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentStep == totalSteps - 1 ? l10n.submit : l10n.continueButton,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError([String? errorMessage]) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.failedToLoadForm,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          if (errorMessage != null) const SizedBox(height: 8),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(serviceFormProvider(widget.serviceId)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2D00D),
              foregroundColor: const Color(0xFF0A192F),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(l10n.retry, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _nextStep(int totalSteps) {
    if (_formKey.currentState?.validate() == true) {
      if (_currentStep < totalSteps - 1) {
        setState(() => _currentStep++);
      } else {
        // Submit form with serviceRequestId
        _submitForm();
      }
    }
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.serviceRequestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.serviceRequestIdMissing)),
      );
      return;
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      
      // Prepare form data
      final formData = <String, dynamic>{};
      for (var entry in _controllers.entries) {
        final value = entry.value.text;
        if (value.isNotEmpty) {
          formData[entry.key] = value;
        }
      }
      formData.addAll(_formValues);
      
      debugPrint('Submitting to: /api/v1/service-requests/${widget.serviceRequestId}/questionnaire');
      debugPrint('Form data: $formData');
      
      // Submit form data using PATCH endpoint
      await apiClient.patch(
        '/api/v1/service-requests/${widget.serviceRequestId}/questionnaire',
        data: formData,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.formSubmittedSuccessfully)),
        );
        context.go('/document-upload?serviceId=${widget.serviceId}&requestId=${widget.serviceRequestId}');
      }
    } catch (e) {
      debugPrint('Form submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorSubmittingForm}: $e')),
        );
      }
    }
  }

  String _getSectionTitle(int step) {
    final l10n = AppLocalizations.of(context)!;
    switch (step) {
      case 0: return l10n.personalData;
      case 1: return l10n.incomeInformation;
      case 2: return l10n.additionalDetails;
      default: return l10n.information;
    }
  }

  TextInputType _getKeyboardType(String type) {
    switch (type) {
      case 'email': return TextInputType.emailAddress;
      case 'phone': return TextInputType.phone;
      case 'number': return TextInputType.number;
      case 'url': return TextInputType.url;
      default: return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters(String type) {
    switch (type) {
      case 'number': return [FilteringTextInputFormatter.digitsOnly];
      case 'phone': return [FilteringTextInputFormatter.digitsOnly];
      default: return [];
    }
  }

  String? _validateField(service_models.FormField field, String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (field.required && (value == null || value.isEmpty)) {
      return l10n.thisFieldIsRequired;
    }
    
    if (value != null && value.isNotEmpty) {
      switch (field.type) {
        case 'email':
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return l10n.pleaseEnterValidEmail;
          }
          break;
        case 'phone':
          if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value)) {
            return l10n.pleaseEnterValidPhoneNumber;
          }
          break;
        case 'url':
          if (!RegExp(r'^https?:\/\/.+').hasMatch(value)) {
            return l10n.pleaseEnterValidUrl;
          }
          break;
      }
    }
    
    return null;
  }

  String _getFieldHint(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    switch (field.type) {
      case 'email': return l10n.nameAtExampleCom;
      case 'phone': return '+1234567890';
      case 'url': return 'https://example.com';
      case 'password': return l10n.enterPassword;
      case 'textarea': return l10n.enterDetailedInformation;
      default:
        switch (field.name) {
          case 'fullName': return l10n.enterYourFullName;
          case 'fiscalCode': return 'e.g. RSSMRA80A01H501W';
          case 'employerName': return l10n.enterEmployerName;
          case 'grossIncome': return l10n.enterGrossIncome;
          default: return '${l10n.enter} ${field.label.toLowerCase()}';
        }
    }
  }

  Future<void> _pickFile(String fieldName) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    
    if (result != null) {
      setState(() {
        _uploadedFiles[fieldName] = result.files;
      });
    }
  }

  void _removeFile(String fieldName, PlatformFile file) {
    setState(() {
      _uploadedFiles[fieldName]?.remove(file);
    });
  }

  void _showColorPicker(String fieldName) {
    final l10n = AppLocalizations.of(context)!;
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectColor),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _formValues[fieldName] = color);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _formValues[fieldName] == color ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
