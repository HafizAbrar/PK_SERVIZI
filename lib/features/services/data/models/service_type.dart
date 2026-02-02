import 'package:json_annotation/json_annotation.dart';

part 'service_type.g.dart';

@JsonSerializable()
class ServiceType {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String category;
  final List<String> requiredDocuments;
  final Map<String, dynamic> formSchema;
  final bool isActive;

  const ServiceType({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.category,
    required this.requiredDocuments,
    required this.formSchema,
    required this.isActive,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) => _$ServiceTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceTypeToJson(this);
}

@JsonSerializable()
class ServiceRequest {
  final String id;
  final String serviceTypeId;
  final String userId;
  final String status;
  final Map<String, dynamic> formData;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double totalAmount;

  const ServiceRequest({
    required this.id,
    required this.serviceTypeId,
    required this.userId,
    required this.status,
    required this.formData,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    required this.totalAmount,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => _$ServiceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceRequestToJson(this);
}

@JsonSerializable()
class Document {
  final String id;
  final String serviceRequestId;
  final String documentType;
  final String fileName;
  final String filePath;
  final String status;
  final DateTime uploadedAt;

  const Document({
    required this.id,
    required this.serviceRequestId,
    required this.documentType,
    required this.fileName,
    required this.filePath,
    required this.status,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentToJson(this);
}

@JsonSerializable()
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}