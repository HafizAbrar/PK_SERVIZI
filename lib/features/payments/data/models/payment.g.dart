// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  userId: json['userId'] as String,
  serviceRequestId: json['serviceRequestId'] as String?,
  subscriptionId: json['subscriptionId'] as String?,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  transactionId: json['transactionId'] as String?,
  receiptUrl: json['receiptUrl'] as String?,
  invoiceUrl: json['invoiceUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  processedAt: json['processedAt'] == null
      ? null
      : DateTime.parse(json['processedAt'] as String),
  description: json['description'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'serviceRequestId': instance.serviceRequestId,
  'subscriptionId': instance.subscriptionId,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'transactionId': instance.transactionId,
  'receiptUrl': instance.receiptUrl,
  'invoiceUrl': instance.invoiceUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'processedAt': instance.processedAt?.toIso8601String(),
  'description': instance.description,
  'metadata': instance.metadata,
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.processing: 'processing',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.cancelled: 'cancelled',
  PaymentStatus.refunded: 'refunded',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.creditCard: 'credit_card',
  PaymentMethod.debitCard: 'debit_card',
  PaymentMethod.paypal: 'paypal',
  PaymentMethod.bankTransfer: 'bank_transfer',
  PaymentMethod.stripe: 'stripe',
};
