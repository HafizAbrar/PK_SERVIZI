import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../data/models/service.dart' as service_models;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/services/translation_service.dart';
import 'service_detail_screen.dart';

final serviceFormProvider = FutureProvider.family<service_models.FormSchema, String>((ref, serviceId) async {
  debugPrint('Loading form schema for serviceId: $serviceId');
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/services/$serviceId');
  debugPrint('Service response: ${response.data}');
  final serviceData = response.data['data'];
  if (serviceData['formSchema'] == null) {
    throw Exception('Form schema not available');
  }
  return service_models.FormSchema.fromJson(serviceData['formSchema']);
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
  service_models.FormSection? _currentSection;
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

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
    final serviceAsync = ref.watch(serviceDetailProvider(widget.serviceId));

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          body: schemaAsync.when(
            data: (schema) => serviceAsync.when(
              data: (service) => _buildForm(schema, service),
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (error, stackTrace) {
                debugPrint('Error loading service: $error');
                return _buildForm(schema, null);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
            error: (error, stackTrace) {
              debugPrint('Error loading form schema: $error');
              return _buildError(error.toString());
            },
          ),
        ),
        if (_isSubmitting) _buildProgressOverlay(),
      ],
    );
  }

  Widget _buildForm(service_models.FormSchema schema, service_models.Service? service) {
    final sections = schema.sections;

    return Column(
      children: [
        _buildAppBar(service),
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormHeader(schema),
                  _buildSectionTiles(sections),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 140),
                ],
              ),
            ),
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildAppBar(service_models.Service? service) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                padding: EdgeInsets.zero,
              ),
              //const Spacer(),
              const SizedBox(width: 60),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/logos/circular_logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),
          if (service != null)
            TranslatedText(
              service.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              l10n.serviceRequest,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final l10n = AppLocalizations.of(context)!;
    final serviceAsync = ref.watch(serviceDetailProvider(widget.serviceId));
    final isFreeService = serviceAsync.maybeWhen(
      data: (service) => double.tryParse(service.basePrice) == 0,
      loading: () => false,
      error: (error, stackTrace) {
        debugPrint('Error loading service in progress bar: $error');
        return false;
      },
      orElse: () => false,
    );

    if (isFreeService) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        color: Colors.white,
        child: Row(
          children: [
            _buildProgressStep(1, '${l10n.form} & ${l10n.documents}', true, false),
            Expanded(child: Container(height: 2, color: Colors.grey[300])),
            _buildProgressStep(2, l10n.submit, false, false),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      color: Colors.white,
      child: Row(
        children: [
          _buildProgressStep(1, l10n.payment, true, true),
          Expanded(child: Container(height: 2, color: AppTheme.accentColor)),
          _buildProgressStep(2, '${l10n.form} & ${l10n.documents}', true, false),
          Expanded(child: Container(height: 2, color: Colors.grey[300])),
          _buildProgressStep(3, l10n.submit, false, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool isCompleted, bool isPast) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.accentColor : Colors.grey[300],
            border: Border.all(
              color: isCompleted ? AppTheme.accentColor : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: isPast
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
              step.toString(),
              style: TextStyle(
                color: isCompleted ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted ? AppTheme.primaryColor : Colors.grey[600],
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }



  Widget _buildFormHeader(service_models.FormSchema schema) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            schema.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
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

  Widget _buildSectionTiles(List<service_models.FormSection> sections) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: sections.map((section) => _buildSectionTile(section)).toList(),
      ),
    );
  }

  Widget _buildSectionTile(service_models.FormSection section) {
    final l10n = AppLocalizations.of(context)!;
    final completedFields = _getSectionCompletedFields(section);
    final totalFields = section.fields.where((f) => f.type != 'hidden').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showSectionDialog(section),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'assets/logos/circular_logo.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      section.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedFields/$totalFields ${l10n.fieldsCompleted}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (completedFields == totalFields)
                    const Icon(Icons.check_circle, color: Colors.green, size: 24)
                  else
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<service_models.FormField> _getSortedFields(List<service_models.FormField> fields) {
    final sorted = List<service_models.FormField>.from(fields);
    sorted.sort((a, b) {
      final orderA = a.order ?? 999;
      final orderB = b.order ?? 999;
      return orderA.compareTo(orderB);
    });
    return sorted;
  }

  void _showSectionDialog(service_models.FormSection section) {
    final l10n = AppLocalizations.of(context)!;
    _currentSection = section;
    final sortedFields = _getSortedFields(section.fields);
    // Initialize controllers for all fields in the section
    for (var field in sortedFields) {
      if (field.type != 'hidden') {
        _controllers[field.name] ??= TextEditingController(
          text: _formValues[field.name]?.toString() ?? '',
        );
        // Initialize controllers for subfields in group fields
        if (field.type == 'group' && field.subFields != null) {
          for (var subField in field.subFields!) {
            _controllers[subField.name] ??= TextEditingController(
              text: _formValues[subField.name]?.toString() ?? '',
            );
            // Initialize formValues for select/radio subfields if not already set
            if ((subField.type == 'select' || subField.type == 'radio') && _formValues[subField.name] == null) {
              _formValues[subField.name] = null;
            }
          }
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TranslatedText(
                          section.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _getSortedFields(section.fields)
                            .where((field) => field.type != 'hidden')
                            .map((field) {
                              // Check if field should be hidden based on dependencies
                              if (field.dependsOn != null || field.conditionalOn != null) {
                                if (_shouldHideField(field, _getSortedFields(section.fields))) {
                                  return const SizedBox.shrink();
                                }
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: field.type == 'checkbox'
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildFieldWidgetWithConditionModal(field, section.fields, setModalState),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TranslatedText(
                                            '${field.label}${field.required ? ' *' : ''}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          _buildFieldWidgetWithConditionModal(field, section.fields, setModalState),
                                        ],
                                      ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          for (var field in _getSortedFields(section.fields)) {
                            debugPrint('Saving field: ${field.name} (${field.type})');
                            switch (field.type) {
                              case 'text':
                              case 'email':
                              case 'phone':
                              case 'number':
                              case 'date':
                              case 'time':
                              case 'datetime':
                              case 'textarea':
                              case 'url':
                              case 'password':
                              case 'signature':
                                final value = _controllers[field.name]?.text;
                                if (value?.isNotEmpty == true) {
                                  _formValues[field.name] = value;
                                  debugPrint('  Saved: ${field.name} = $value');
                                }
                                break;
                              case 'group':
                                // Save subfield values for group fields
                                if (field.subFields != null) {
                                  for (var subField in field.subFields!) {
                                    debugPrint('  Saving subfield: ${subField.name} (${subField.type})');
                                    switch (subField.type) {
                                      case 'text':
                                      case 'email':
                                      case 'phone':
                                      case 'number':
                                      case 'date':
                                      case 'time':
                                      case 'datetime':
                                      case 'textarea':
                                      case 'url':
                                      case 'password':
                                      case 'signature':
                                        final value = _controllers[subField.name]?.text;
                                        if (value?.isNotEmpty == true) {
                                          _formValues[subField.name] = value;
                                          debugPrint('    Saved: ${subField.name} = $value');
                                        }
                                        break;
                                      case 'select':
                                      case 'radio':
                                        final value = _formValues[subField.name];
                                        if (value != null) {
                                          debugPrint('    Saved: ${subField.name} = $value');
                                        }
                                        break;
                                      case 'file':
                                        final files = _uploadedFiles[subField.name];
                                        if (files != null && files.isNotEmpty) {
                                          _formValues[subField.name] = files;
                                          debugPrint('    Saved: ${subField.name} = ${files.length} files');
                                        }
                                        break;
                                    }
                                  }
                                }
                                break;
                              case 'select':
                              case 'radio':
                                final value = _formValues[field.name];
                                if (value != null) {
                                  debugPrint('  Saved: ${field.name} = $value');
                                }
                                break;
                              case 'checkbox':
                                final value = _formValues[field.name];
                                if (value != null) {
                                  debugPrint('  Saved: ${field.name} = $value');
                                }
                                break;
                              case 'file':
                                final files = _uploadedFiles[field.name];
                                if (files != null && files.isNotEmpty) {
                                  _formValues[field.name] = files;
                                  debugPrint('  Saved: ${field.name} = ${files.length} files');
                                }
                                break;
                            }
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.saveDraft,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _shouldHideField(service_models.FormField field, List<service_models.FormField> allFields) {
    // Check API-provided dependsOn condition first
    if (field.dependsOn != null) {
      final dependsOn = field.dependsOn!;
      final dependentFieldValue = _formValues[dependsOn['field']]?.toString();
      
      if (dependsOn.containsKey('value')) {
        // Show only if dependent field equals specified value
        if (dependentFieldValue != dependsOn['value']) {
          return true;
        }
      } else if (dependsOn.containsKey('isNot') && dependsOn['isNot'] == true) {
        // Show only if dependent field does NOT equal specified value
        if (dependentFieldValue == dependsOn['value']) {
          return true;
        }
      }
    }
    
    // Fallback to keyword-matching logic for backward compatibility
    final fieldNameLower = field.name.toLowerCase();
    final fieldLabelLower = field.label.toLowerCase();
    
    final hasDocKeyword = fieldNameLower.contains('document') || 
                         fieldNameLower.contains('receipt') ||
                         fieldLabelLower.contains('document') ||
                         fieldLabelLower.contains('receipt') ||
                         fieldNameLower.contains('file') ||
                         fieldNameLower.contains('upload');
    
    for (var radioField in allFields) {
      if (radioField.type == 'radio') {
        final selectedValue = _formValues[radioField.name]?.toString().toLowerCase();
        final radioNameLower = radioField.name.toLowerCase();
        final radioLabelLower = radioField.label.toLowerCase();
        
        final fieldKeywords = _extractKeywords(fieldNameLower + ' ' + fieldLabelLower);
        final radioKeywords = _extractKeywords(radioNameLower + ' ' + radioLabelLower);
        final hasCommonKeyword = fieldKeywords.any((kw) => radioKeywords.contains(kw));
        
        if (hasCommonKeyword) {
          if (hasDocKeyword && (selectedValue == 'no' || selectedValue == 'false' || selectedValue == '0' || selectedValue == 'sì')) {
            return selectedValue == 'no' || selectedValue == 'false' || selectedValue == '0';
          }
          if (!hasDocKeyword && field.type != 'radio' && (selectedValue == 'no' || selectedValue == 'false' || selectedValue == '0')) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Widget _buildFieldWidgetWithConditionModal(service_models.FormField field, List<service_models.FormField> allFields, StateSetter setModalState) {
    if (_shouldHideField(field, allFields)) {
      return const SizedBox.shrink();
    }
    return _buildFieldWidgetModal(field, setModalState);
  }

  List<String> _extractKeywords(String text) {
    return text
        .split(RegExp(r'[\s_-]+'))
        .where((word) => word.length > 2 && !['the', 'and', 'for', 'you', 'are', 'have', 'do', 'or'].contains(word))
        .toList();
  }

  Widget _buildFieldWidgetModal(service_models.FormField field, StateSetter setModalState) {
    switch (field.type) {
      case 'radio':
        return _buildRadioFieldModal(field, setModalState);
      case 'group':
        return _buildGroupFieldModal(field, setModalState);
      case 'dynamic_list':
        return _buildDynamicListField(field);
      case 'date':
        return _buildDateFieldModal(field, setModalState);
      default:
        return _buildFieldWidget(field);
    }
  }

  Widget _buildGroupFieldModal(service_models.FormField field, StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.description != null) ...[
            Text(
              field.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
          ],
          ...?field.subFields?.map((subField) {
            // Initialize controller for subfield if not exists
            _controllers[subField.name] ??= TextEditingController(
              text: _formValues[subField.name]?.toString() ?? '',
            );
            
            // Only check if the subField itself should be hidden, not the parent group
            if (subField.dependsOn != null || subField.conditionalOn != null) {
              if (_shouldHideField(subField, field.subFields ?? [])) {
                return const SizedBox.shrink();
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    '${subField.label}${subField.required ? ' *' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildFieldWidgetModal(subField, setModalState),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRadioFieldModal(service_models.FormField field, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...field.options?.map((option) => RadioListTile<String>(
          title: TranslatedText(option),
          value: option,
          groupValue: _formValues[field.name],
          onChanged: (value) {
            setState(() {
              _formValues[field.name] = value;
            });
            setModalState(() {});
          },
          contentPadding: EdgeInsets.zero,
        )).toList() ?? [],
      ],
    );
  }

  Widget _buildDateFieldModal(service_models.FormField field, StateSetter setModalState) {
    final l10n = AppLocalizations.of(context)!;
    final fieldNameLower = field.name.toLowerCase();
    final fieldLabelLower = field.label.toLowerCase();
    final isExpiryDate = fieldNameLower.contains('expiry') || 
                         fieldNameLower.contains('expiration') ||
                         fieldLabelLower.contains('expiry') ||
                         fieldLabelLower.contains('expiration') ||
                         fieldLabelLower.contains('scadenza');
    
    // Ensure controller exists
    _controllers[field.name] ??= TextEditingController(
      text: _formValues[field.name]?.toString() ?? '',
    );
    
    return TextFormField(
      controller: _controllers[field.name],
      readOnly: true,
      decoration: InputDecoration(
        hintText: _getPlaceholderText(field, l10n.selectDate),
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
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
          lastDate: isExpiryDate ? DateTime(2100) : DateTime.now(),
        );
        if (date != null) {
          final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          _controllers[field.name]!.text = formattedDate;
          _formValues[field.name] = formattedDate;
          setModalState(() {});
          setState(() {});
        }
      },
      validator: (value) => _validateField(field, value),
    );
  }

  String? _getFieldValue(service_models.FormField field) {
    // First check if value exists in _formValues (for fields saved from modal)
    final formValue = _formValues[field.name]?.toString();
    if (formValue != null && formValue.isNotEmpty) {
      return formValue;
    }
    
    // Then check controller for text-based fields
    if (field.type == 'text' || field.type == 'email' ||
        field.type == 'phone' || field.type == 'number' ||
        field.type == 'date' || field.type == 'time' ||
        field.type == 'signature') {
      final value = _controllers[field.name]?.text;
      return value?.isNotEmpty == true ? value : null;
    }
    
    // For group fields, check if all required subfields have values
    if (field.type == 'group' && field.subFields != null) {
      bool allSubFieldsFilled = true;
      for (var subField in field.subFields!) {
        if (subField.required) {
          final subValue = _getFieldValue(subField);
          if (subValue == null || subValue.isEmpty) {
            allSubFieldsFilled = false;
            debugPrint('  Group subfield missing: ${subField.name} (${subField.label})');
            break;
          }
        }
      }
      return allSubFieldsFilled ? 'group_filled' : null;
    }
    
    return null;
  }

  Widget _buildFieldWidget(service_models.FormField field) {
    switch (field.type) {
      case 'group':
        return _buildGroupField(field);
      case 'dynamic_list':
        return _buildDynamicListField(field);
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
      case 'signature':
        return _buildSignatureField(field);
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
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return TextFormField(
          controller: _controllers[field.name],
          keyboardType: _getKeyboardType(field.type),
          obscureText: field.type == 'password',
          inputFormatters: _getInputFormatters(field.type),
          onChanged: (value) {
            _formValues[field.name] = value;
            setLocalState(() {});
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: _getPlaceholderText(field),
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: field.type == 'password' ? const Icon(Icons.visibility_off) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[100]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) => _validateField(field, value),
        );
      },
    );
  }

  Widget _buildTextAreaField(service_models.FormField field) {
    return TextFormField(
      controller: _controllers[field.name],
      maxLines: 4,
      decoration: InputDecoration(
        hintText: _getPlaceholderText(field),
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildCheckboxField(service_models.FormField field) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return CheckboxListTile(
          title: TranslatedText('${field.label}${field.required ? ' *' : ''}'),
          value: _formValues[field.name] ?? false,
          onChanged: (value) {
            setModalState(() {
              _formValues[field.name] = value;
            });
            setState(() {
              _formValues[field.name] = value;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildRadioField(service_models.FormField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...field.options?.map((option) => RadioListTile<String>(
          title: TranslatedText(option),
          value: option,
          groupValue: _formValues[field.name],
          onChanged: (value) {
            setState(() {
              _formValues[field.name] = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        )).toList() ?? [],
      ],
    );
  }

  Widget _buildFileField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    return StatefulBuilder(
      builder: (context, setModalState) {
        final files = _uploadedFiles[field.name] ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickFile(field.name, setModalState),
                    child: Container(
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
                              color: AppTheme.primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.upload_file, color: AppTheme.accentColor, size: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.chooseFile,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _pickImageFromCamera(field.name, setModalState),
                  child: Container(
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
                            color: AppTheme.primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.camera_alt, color: AppTheme.accentColor, size: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.camera,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (files.isNotEmpty) ...
            files.map((file) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16, color: AppTheme.accentColor),
                  Expanded(child: Text(file.name, style: const TextStyle(fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => _removeFile(field.name, file, setModalState),
                  ),
                ],
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildTimeField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _controllers[field.name],
      readOnly: true,
      decoration: InputDecoration(
        hintText: _getPlaceholderText(field, l10n.selectTime),
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: const Icon(Icons.access_time, color: AppTheme.accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
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
        hintText: _getPlaceholderText(field, l10n.selectDateAndTime),
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: const Icon(Icons.event, color: AppTheme.accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
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
    return StatefulBuilder(
      builder: (context, setModalState) {
        final value = _formValues[field.name] ?? 0.0;
        return Column(
          children: [
            Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              label: value.round().toString(),
              onChanged: (newValue) {
                setModalState(() {
                  _formValues[field.name] = newValue;
                });
                setState(() {
                  _formValues[field.name] = newValue;
                });
              },
            ),
            Text('${l10n.value}: ${value.round()}'),
          ],
        );
      },
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
    return StatefulBuilder(
      builder: (context, setModalState) {
        return DropdownButtonFormField<String>(
          value: _formValues[field.name],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[100]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Colors.white,
          ),
          items: field.options?.map((option) => DropdownMenuItem(value: option, child: TranslatedText(option))).toList(),
          onChanged: (value) {
            setModalState(() {
              _formValues[field.name] = value;
            });
            setState(() {
              _formValues[field.name] = value;
            });
          },
          validator: (value) => _validateField(field, value?.toString()),
        );
      },
    );
  }

  Widget _buildDateField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    final fieldNameLower = field.name.toLowerCase();
    final fieldLabelLower = field.label.toLowerCase();
    final isExpiryDate = fieldNameLower.contains('expiry') || 
                         fieldNameLower.contains('expiration') ||
                         fieldLabelLower.contains('expiry') ||
                         fieldLabelLower.contains('expiration') ||
                         fieldLabelLower.contains('scadenza');
    
    // Ensure controller exists
    _controllers[field.name] ??= TextEditingController(
      text: _formValues[field.name]?.toString() ?? '',
    );
    
    return TextFormField(
      controller: _controllers[field.name],
      readOnly: true,
      decoration: InputDecoration(
        hintText: _getPlaceholderText(field, l10n.selectDate),
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
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
          lastDate: isExpiryDate ? DateTime(2100) : DateTime.now(),
        );
        if (date != null) {
          final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          setState(() {
            _controllers[field.name]!.text = formattedDate;
            _formValues[field.name] = formattedDate;
          });
        }
      },
      validator: (value) => _validateField(field, value),
    );
  }



  Widget _buildGroupField(service_models.FormField field) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.description != null) ...[
            Text(
              field.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
          ],
          ...?field.subFields?.map((subField) {
            // Only check if the subField itself should be hidden, not the parent group
            if (subField.dependsOn != null || subField.conditionalOn != null) {
              if (_shouldHideField(subField, field.subFields ?? [])) {
                return const SizedBox.shrink();
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    '${subField.label}${subField.required ? ' *' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildFieldWidget(subField),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDynamicListField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    final items = _formValues[field.name] as List<Map<String, dynamic>>? ?? [];
    
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.description != null) ...[
              Text(
                field.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
            ],
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${l10n.information} ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setModalState(() {
                              items.removeAt(index);
                              _formValues[field.name] = items;
                            });
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    ...?field.subFields?.map((subField) {
                      final fieldKey = '${field.name}[$index].${subField.name}';
                      _controllers[fieldKey] ??= TextEditingController();
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TranslatedText(
                              '${subField.label}${subField.required ? ' *' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildFieldWidget(subField),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                setModalState(() {
                  items.add({});
                  _formValues[field.name] = items;
                });
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${l10n.enter} '),
                  TranslatedText(field.label),
                ],
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentColor,
                side: const BorderSide(color: AppTheme.accentColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignatureField(service_models.FormField field) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _controllers[field.name],
      decoration: InputDecoration(
        hintText: _getPlaceholderText(field, l10n.enterYourFullName),
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: const Icon(Icons.edit, color: AppTheme.accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildBottomActions() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
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
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.submit,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 20),
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
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.primaryColor,
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

  int _getSectionCompletedFields(service_models.FormSection section) {
    int completed = 0;
    for (var field in section.fields) {
      if (field.type == 'hidden') continue;

      bool hasValue = false;

      switch (field.type) {
        case 'group':
          // Check if all required subfields are filled
          if (field.subFields != null) {
            hasValue = field.subFields!.every((subField) {
              if (!subField.required) return true;
              final value = _getFieldValue(subField);
              return value != null && value.isNotEmpty;
            });
          }
          break;
        case 'dynamic_list':
          final items = _formValues[field.name] as List?;
          hasValue = items != null && items.isNotEmpty;
          break;
        case 'checkbox':
          hasValue = _formValues[field.name] == true;
          break;
        case 'select':
        case 'radio':
          hasValue = _formValues[field.name] != null;
          break;
        case 'file':
          hasValue = _uploadedFiles[field.name]?.isNotEmpty == true;
          break;
        case 'range':
          hasValue = _formValues[field.name] != null;
          break;
        case 'color':
          hasValue = _formValues[field.name] != null;
          break;
        default:
        // For text, email, phone, number, date, time, etc.
          final controllerValue = _controllers[field.name]?.text;
          final formValue = _formValues[field.name]?.toString();
          hasValue = (controllerValue?.isNotEmpty == true) || (formValue?.isNotEmpty == true);
      }

      if (hasValue) {
        completed++;
      }
    }
    return completed;
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.thisFieldIsRequired),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    final schemaAsync = ref.read(serviceFormProvider(widget.serviceId));
    final schema = schemaAsync.value;
    
    if (schema != null) {
      for (var section in schema.sections) {
        for (var field in section.fields) {
          if (field.required && field.type != 'hidden') {
            if (_shouldHideField(field, section.fields)) continue;
            
            final value = _getFieldValue(field);
            if (value == null || value.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.thisFieldIsRequired}: ${field.label}'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              return;
            }
          }
        }
      }
    }
    
    if (widget.serviceRequestId == null || widget.serviceRequestId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.serviceRequestIdMissing),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
        _uploadProgress = 0.0;
        _uploadStatus = 'Preparing submission...';
      });

      final apiClient = ref.read(apiClientProvider);

      // Build questionnaire answers (text only)
      final answersMap = <String, dynamic>{};

      for (var entry in _controllers.entries) {
        final value = entry.value.text.trim();
        if (value.isNotEmpty) answersMap[entry.key] = value;
      }

      for (var entry in _formValues.entries) {
        if (entry.value != null && 
            entry.value is! List<PlatformFile> &&
            entry.value is! List) {
          answersMap[entry.key] = entry.value;
        }
      }

      // Build multipart form data
      final formData = FormData();
      formData.fields.add(MapEntry('formData', jsonEncode(answersMap)));

      // Map form field names to API expected field names
      const fileFieldMapping = {
        'document_file': 'identityDocument',
        'carta_identita': 'identityDocument',
        'passaporto': 'identityDocument',
        'tax_card_file': 'fiscalCode',
        'codice_fiscale': 'fiscalCode',
        'cf_coniuge': 'fiscalCode',
        'income_file': 'incomeCertificate',
        'certificato_reddito': 'incomeCertificate',
        'bank_statement': 'bankStatement',
        'estratto_conto': 'bankStatement',
        'property_document': 'propertyDocument',
        'documento_proprieta': 'propertyDocument',
        'visura_catastale': 'visuraCatastale',
        'cu_certificate': 'cuCertificate',
        'certificazione_unica': 'cuCertificate',
        'property_deed': 'propertyDeed',
        'atto_proprieta': 'propertyDeed',
        'permit_file': 'identityDocument',
        'permesso_soggiorno': 'identityDocument',
        'atto_nascita': 'otherDocument',
        'certificato_penale': 'otherDocument',
        'atto_matrimonio': 'familyDocuments',
        'stato_famiglia': 'familyDocuments',
        'versamento_250': 'otherDocument',
        'certificato_lingua': 'otherDocument',
        'marca_bollo': 'otherDocument',
        'doc_coniuge': 'familyDocuments',
      };

      // Group files by API field name to handle arrays
      final filesByApiField = <String, List<PlatformFile>>{};
      for (var entry in _uploadedFiles.entries) {
        if (entry.value.isNotEmpty) {
          final apiFieldName = fileFieldMapping[entry.key] ?? 'otherDocument';
          filesByApiField[apiFieldName] ??= [];
          filesByApiField[apiFieldName]!.addAll(entry.value);
        }
      }

      // Add files - for array fields, send multiple files with same field name
      for (var entry in filesByApiField.entries) {
        final fieldName = entry.key;
        final files = entry.value;
        
        for (var file in files) {
          if (file.bytes != null) {
            formData.files.add(MapEntry(fieldName, MultipartFile.fromBytes(file.bytes!, filename: file.name)));
          } else if (file.path != null) {
            formData.files.add(MapEntry(fieldName, await MultipartFile.fromFile(file.path!, filename: file.name)));
          }
        }
      }

      debugPrint('Submitting with ${filesByApiField.length} file field types');
      debugPrint('File fields: ${filesByApiField.keys.toList()}');

      final response = await apiClient.dio.patch(
        '/api/v1/service-requests/${widget.serviceRequestId}/questionnaire',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: (sent, total) {
          setState(() {
            _uploadProgress = sent / total;
            _uploadStatus = 'Uploading... ${(sent / 1024 / 1024).toStringAsFixed(1)}MB / ${(total / 1024 / 1024).toStringAsFixed(1)}MB';
          });
        },
      );

      setState(() {
        _isSubmitting = false;
        _uploadProgress = 0.0;
        _uploadStatus = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.formSubmittedSuccessfully),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/request-submission?requestId=${widget.serviceRequestId}');
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint('Form submission error: ${e.response?.data}');
      }
      setState(() {
        _isSubmitting = false;
        _uploadProgress = 0.0;
        _uploadStatus = '';
      });
      if (mounted) {
        String errorMessage;
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('401')) {
          errorMessage = 'Your session has expired. Please log in again.';
        } else if (errorString.contains('403')) {
          errorMessage = 'You do not have permission to perform this action.';
        } else if (errorString.contains('404')) {
          errorMessage = 'The requested resource was not found.';
        } else if (errorString.contains('500') || errorString.contains('502') || errorString.contains('503')) {
          errorMessage = 'Server error. Please try again later.';
        } else if (errorString.contains('network') || errorString.contains('socket')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (errorString.contains('timeout')) {
          errorMessage = 'Request timeout. Please try again.';
        } else {
          errorMessage = '${l10n.errorSubmittingForm}. ${l10n.pleaseTryAgain}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
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

  Future<void> _pickImageFromCamera(String fieldName, StateSetter setModalState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final platformFile = PlatformFile(
        name: image.name,
        size: bytes.length,
        bytes: bytes,
        path: image.path,
      );

      _uploadedFiles[fieldName] ??= [];
      _uploadedFiles[fieldName]!.add(platformFile);

      setModalState(() {});
      setState(() {});
    }
  }

  Future<void> _pickFile(String fieldName, StateSetter setModalState) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setModalState(() {
        _uploadedFiles[fieldName] = result.files;
      });
      setState(() {
        _uploadedFiles[fieldName] = result.files;
      });
    }
  }

  void _removeFile(String fieldName, PlatformFile file, StateSetter setModalState) {
    setModalState(() {
      _uploadedFiles[fieldName]?.remove(file);
    });
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

  String _getPlaceholderText(service_models.FormField field, [String? defaultText]) {
    if (field.placeholder != null && field.placeholder!.isNotEmpty) {
      return _translateHint(field.placeholder!);
    }
    return defaultText ?? _getFieldHint(field);
  }

  String _translateHint(String hint) {
    final locale = Localizations.localeOf(context).languageCode;
    return TranslationService.getCached(hint, locale) ?? hint;
  }

  Future<List<int>?> _readFileBytes(String path) async {
    try {
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  Widget _buildProgressOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                    ),
                  ),
                  Text(
                    '${(_uploadProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _uploadStatus,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}