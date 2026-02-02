// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceType _$ServiceTypeFromJson(Map<String, dynamic> json) => ServiceType(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  basePrice: (json['basePrice'] as num).toDouble(),
  category: json['category'] as String,
  requiredDocuments: (json['requiredDocuments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  formSchema: json['formSchema'] as Map<String, dynamic>,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$ServiceTypeToJson(ServiceType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'basePrice': instance.basePrice,
      'category': instance.category,
      'requiredDocuments': instance.requiredDocuments,
      'formSchema': instance.formSchema,
      'isActive': instance.isActive,
    };

ServiceRequest _$ServiceRequestFromJson(Map<String, dynamic> json) =>
    ServiceRequest(
      id: json['id'] as String,
      serviceTypeId: json['serviceTypeId'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
      formData: json['formData'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );

Map<String, dynamic> _$ServiceRequestToJson(ServiceRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceTypeId': instance.serviceTypeId,
      'userId': instance.userId,
      'status': instance.status,
      'formData': instance.formData,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'totalAmount': instance.totalAmount,
    };

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
  id: json['id'] as String,
  serviceRequestId: json['serviceRequestId'] as String,
  documentType: json['documentType'] as String,
  fileName: json['fileName'] as String,
  filePath: json['filePath'] as String,
  status: json['status'] as String,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
);

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
  'id': instance.id,
  'serviceRequestId': instance.serviceRequestId,
  'documentType': instance.documentType,
  'fileName': instance.fileName,
  'filePath': instance.filePath,
  'status': instance.status,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
};

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
