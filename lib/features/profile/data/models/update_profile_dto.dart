import 'package:json_annotation/json_annotation.dart';

part 'update_profile_dto.g.dart';

@JsonSerializable()
class UpdateProfileDto {
  final String email;
  final String? password;
  final String fullName;
  final String fiscalCode;
  final String phone;
  final bool isActive;
  final String roleId;
  final bool skipWelcomeEmail;

  UpdateProfileDto({
    required this.email,
    this.password,
    required this.fullName,
    required this.fiscalCode,
    required this.phone,
    required this.isActive,
    required this.roleId,
    required this.skipWelcomeEmail,
  });

  factory UpdateProfileDto.fromJson(Map<String, dynamic> json) => _$UpdateProfileDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileDtoToJson(this);
}
