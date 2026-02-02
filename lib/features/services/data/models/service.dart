import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final String id;
  final String name;
  final String code;
  final String description;
  final String category;
  final String basePrice;
  final List<RequiredDocument> requiredDocuments;
  final FormSchema? formSchema;
  final bool isActive;
  final String serviceTypeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ServiceTypeInfo? serviceType;

  const Service({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.requiredDocuments,
    this.formSchema,
    required this.isActive,
    required this.serviceTypeId,
    required this.createdAt,
    required this.updatedAt,
    this.serviceType,
  });

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}

@JsonSerializable()
class RequiredDocument {
  final String name;
  final String category;
  final bool required;

  const RequiredDocument({
    required this.name,
    required this.category,
    required this.required,
  });

  factory RequiredDocument.fromJson(Map<String, dynamic> json) => _$RequiredDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$RequiredDocumentToJson(this);
}

@JsonSerializable()
class FormSchema {
  final String title;
  final List<FormSection> sections;

  const FormSchema({
    required this.title,
    required this.sections,
  });

  factory FormSchema.fromJson(Map<String, dynamic> json) => _$FormSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$FormSchemaToJson(this);
}

@JsonSerializable()
class FormSection {
  final String title;
  final List<FormField> fields;

  const FormSection({
    required this.title,
    required this.fields,
  });

  factory FormSection.fromJson(Map<String, dynamic> json) => _$FormSectionFromJson(json);
  Map<String, dynamic> toJson() => _$FormSectionToJson(this);
}

@JsonSerializable()
class FormField {
  final String name;
  final String type;
  final String label;
  final bool required;
  final List<String>? options;

  const FormField({
    required this.name,
    required this.type,
    required this.label,
    required this.required,
    this.options,
  });

  factory FormField.fromJson(Map<String, dynamic> json) => _$FormFieldFromJson(json);
  Map<String, dynamic> toJson() => _$FormFieldToJson(this);
}

@JsonSerializable()
class ServiceTypeInfo {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceTypeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceTypeInfo.fromJson(Map<String, dynamic> json) => _$ServiceTypeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceTypeInfoToJson(this);
}