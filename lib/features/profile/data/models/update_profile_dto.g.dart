// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileDto _$UpdateProfileDtoFromJson(Map<String, dynamic> json) =>
    UpdateProfileDto(
      email: json['email'] as String,
      password: json['password'] as String?,
      fullName: json['fullName'] as String,
      fiscalCode: json['fiscalCode'] as String,
      phone: json['phone'] as String,
      isActive: json['isActive'] as bool,
      roleId: json['roleId'] as String,
      skipWelcomeEmail: json['skipWelcomeEmail'] as bool,
    );

Map<String, dynamic> _$UpdateProfileDtoToJson(UpdateProfileDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'fullName': instance.fullName,
      'fiscalCode': instance.fiscalCode,
      'phone': instance.phone,
      'isActive': instance.isActive,
      'roleId': instance.roleId,
      'skipWelcomeEmail': instance.skipWelcomeEmail,
    };
