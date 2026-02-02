// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
