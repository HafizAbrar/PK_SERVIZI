import 'package:json_annotation/json_annotation.dart';

part 'register_request_dto.g.dart';

@JsonSerializable()
class RegisterRequestDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String fiscalCode;
  final String phone;
  final String dateOfBirth;
  final String address;
  final String city;
  final String postalCode;
  final String province;
  final bool gdprConsent;
  final bool marketingConsent;

  RegisterRequestDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.fiscalCode,
    required this.phone,
    required this.dateOfBirth,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.province,
    required this.gdprConsent,
    required this.marketingConsent,
  });

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}
