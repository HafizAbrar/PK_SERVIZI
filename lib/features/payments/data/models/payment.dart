import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final String id;
  final String userId;
  final String? serviceRequestId;
  final String? subscriptionId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? receiptUrl;
  final String? invoiceUrl;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? description;
  final Map<String, dynamic>? metadata;

  const Payment({
    required this.id,
    required this.userId,
    this.serviceRequestId,
    this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    this.transactionId,
    this.receiptUrl,
    this.invoiceUrl,
    required this.createdAt,
    this.processedAt,
    this.description,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}

@JsonEnum()
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
}

@JsonEnum()
enum PaymentMethod {
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('debit_card')
  debitCard,
  @JsonValue('paypal')
  paypal,
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('stripe')
  stripe,
}