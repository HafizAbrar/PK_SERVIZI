class RegisterRequestDto {
  final String email;
  final String password;
  final String fullName;
  final String? phone;

  RegisterRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'email': email,
      'password': password,
      'fullName': fullName,
    };
    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone!;
    }
    return json;
  }
}
