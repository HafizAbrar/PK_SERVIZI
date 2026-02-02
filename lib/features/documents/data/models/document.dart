import 'package:json_annotation/json_annotation.dart';

part 'document.g.dart';

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