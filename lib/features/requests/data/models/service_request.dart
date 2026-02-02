import 'package:json_annotation/json_annotation.dart';

part 'service_request.g.dart';

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