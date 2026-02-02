import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final String id;
  final String userId;
  final String serviceType;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Appointment({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}