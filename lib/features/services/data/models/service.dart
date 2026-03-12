import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

class _BasePriceConverter implements JsonConverter<String, dynamic> {
  const _BasePriceConverter();

  @override
  String fromJson(dynamic json) {
    try {
      if (json == null) return '0';
      if (json is String) return json;
      if (json is int) return json.toString();
      if (json is double) return json.toString();
      return json.toString();
    } catch (e) {
      return '0';
    }
  }

  @override
  dynamic toJson(String object) => object;
}

@JsonSerializable()
class Service {
  final String id;
  final String name;
  final String code;
  final String description;
  final String category;
  @_BasePriceConverter()
  final String basePrice;
  final List<String> requiredDocuments;
  final String? documentRequirements;
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
    this.documentRequirements,
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
  final List<FormField>? subFields;
  final Map<String, dynamic>? dependsOn;
  final Map<String, dynamic>? conditionalOn;
  final String? placeholder;
  final String? description;
  final int? order;
  final int? maxLength;
  final String? defaultValue;
  final String? accept;
  final bool? multiple;

  const FormField({
    required this.name,
    required this.type,
    required this.label,
    required this.required,
    this.options,
    this.subFields,
    this.dependsOn,
    this.conditionalOn,
    this.placeholder,
    this.description,
    this.order,
    this.maxLength,
    this.defaultValue,
    this.accept,
    this.multiple,
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
