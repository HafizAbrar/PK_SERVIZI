// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
