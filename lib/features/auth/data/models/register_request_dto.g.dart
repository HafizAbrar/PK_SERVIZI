// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestDto _$RegisterRequestDtoFromJson(Map<String, dynamic> json) =>
    RegisterRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fiscalCode: json['fiscalCode'] as String,
      phone: json['phone'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      province: json['province'] as String,
      gdprConsent: json['gdprConsent'] as bool,
      marketingConsent: json['marketingConsent'] as bool,
    );

Map<String, dynamic> _$RegisterRequestDtoToJson(RegisterRequestDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fiscalCode': instance.fiscalCode,
      'phone': instance.phone,
      'dateOfBirth': instance.dateOfBirth,
      'address': instance.address,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'province': instance.province,
      'gdprConsent': instance.gdprConsent,
      'marketingConsent': instance.marketingConsent,
    };
