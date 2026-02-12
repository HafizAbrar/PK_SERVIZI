class Invoice {
  final String id;
  final String invoiceNumber;
  final String amount;
  final String currency;
  final String status;
  final String issuedAt;
  final String? paidAt;
  final List<LineItem> lineItems;
  final Map<String, dynamic>? billing;
  final Map<String, dynamic>? payment;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.currency,
    required this.status,
    required this.issuedAt,
    this.paidAt,
    required this.lineItems,
    this.billing,
    this.payment,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      amount: json['amount'],
      currency: json['currency'],
      status: json['status'],
      issuedAt: json['issuedAt'],
      paidAt: json['paidAt'],
      lineItems: (json['lineItems'] as List).map((e) => LineItem.fromJson(e)).toList(),
      billing: json['billing'],
      payment: json['payment'],
    );
  }
}

class Payment {
  final String id;
  final String amount;
  final String currency;
  final String status;
  final String description;
  final String? paidAt;
  final String createdAt;
  final String? subscriptionId;
  final String? serviceRequestId;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    this.paidAt,
    required this.createdAt,
    this.subscriptionId,
    this.serviceRequestId,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'],
      currency: json['currency'],
      status: json['status'],
      description: json['description'],
      paidAt: json['paidAt'],
      createdAt: json['createdAt'],
      subscriptionId: json['subscriptionId'],
      serviceRequestId: json['serviceRequestId'],
      metadata: json['metadata'],
    );
  }
}

class LineItem {
  final String description;
  final String amount;

  LineItem({required this.description, required this.amount});

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(description: json['description'], amount: json['amount']);
  }
}
