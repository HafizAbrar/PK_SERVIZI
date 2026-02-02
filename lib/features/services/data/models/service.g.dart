// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  basePrice: json['basePrice'] as String,
  requiredDocuments: (json['requiredDocuments'] as List<dynamic>)
      .map((e) => RequiredDocument.fromJson(e as Map<String, dynamic>))
      .toList(),
  formSchema: json['formSchema'] == null
      ? null
      : FormSchema.fromJson(json['formSchema'] as Map<String, dynamic>),
  isActive: json['isActive'] as bool,
  serviceTypeId: json['serviceTypeId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  serviceType: json['serviceType'] == null
      ? null
      : ServiceTypeInfo.fromJson(json['serviceType'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'description': instance.description,
  'category': instance.category,
  'basePrice': instance.basePrice,
  'requiredDocuments': instance.requiredDocuments,
  'formSchema': instance.formSchema,
  'isActive': instance.isActive,
  'serviceTypeId': instance.serviceTypeId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'serviceType': instance.serviceType,
};

RequiredDocument _$RequiredDocumentFromJson(Map<String, dynamic> json) =>
    RequiredDocument(
      name: json['name'] as String,
      category: json['category'] as String,
      required: json['required'] as bool,
    );

Map<String, dynamic> _$RequiredDocumentToJson(RequiredDocument instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'required': instance.required,
    };

FormSchema _$FormSchemaFromJson(Map<String, dynamic> json) => FormSchema(
  title: json['title'] as String,
  sections: (json['sections'] as List<dynamic>)
      .map((e) => FormSection.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FormSchemaToJson(FormSchema instance) =>
    <String, dynamic>{'title': instance.title, 'sections': instance.sections};

FormSection _$FormSectionFromJson(Map<String, dynamic> json) => FormSection(
  title: json['title'] as String,
  fields: (json['fields'] as List<dynamic>)
      .map((e) => FormField.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FormSectionToJson(FormSection instance) =>
    <String, dynamic>{'title': instance.title, 'fields': instance.fields};

FormField _$FormFieldFromJson(Map<String, dynamic> json) => FormField(
  name: json['name'] as String,
  type: json['type'] as String,
  label: json['label'] as String,
  required: json['required'] as bool,
  options: (json['options'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$FormFieldToJson(FormField instance) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'label': instance.label,
  'required': instance.required,
  'options': instance.options,
};

ServiceTypeInfo _$ServiceTypeInfoFromJson(Map<String, dynamic> json) =>
    ServiceTypeInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ServiceTypeInfoToJson(ServiceTypeInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
