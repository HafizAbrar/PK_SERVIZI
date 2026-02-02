class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message) : super(statusCode: 400);
}

class UnauthorizedException extends AppException {
  UnauthorizedException() : super('Unauthorized', statusCode: 401);
}

class ServerException extends AppException {
  ServerException(super.message) : super(statusCode: 500);
}
