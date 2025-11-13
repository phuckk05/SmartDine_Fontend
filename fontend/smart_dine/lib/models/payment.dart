class PaymentStatus {
  final String id;
  final String code; // PENDING, CONFIRMED, CANCELLED
  final String name;

  PaymentStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      id: _asString(json['id']),
      code: _asString(json['code']),
      name: _asString(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class PaymentMethod {
  final String id;
  final String code; // CASH, MOMO, VNPAY, CREDIT_CARD
  final String name;

  PaymentMethod({
    required this.id,
    required this.code,
    required this.name,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: _asString(json['id']),
      code: _asString(json['code']),
      name: _asString(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class PaymentDetail {
  final String paymentId;
  final String companyPaymentMethodId;
  final double amount;

  // Relations
  PaymentMethod? paymentMethod;

  PaymentDetail({
    required this.paymentId,
    required this.companyPaymentMethodId,
    required this.amount,
    this.paymentMethod,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      paymentId: _asString(json['payment_id'] ?? json['paymentId']),
      companyPaymentMethodId:
          _asString(json['company_payment_method_id'] ?? json['companyPaymentMethodId']),
      amount: _asDouble(json['amount']),
      paymentMethod: json['payment_method'] != null
          ? PaymentMethod.fromJson(json['payment_method'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'company_payment_method_id': companyPaymentMethodId,
      'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod!.toJson(),
    };
  }
}

class Payment {
  final String id;
  final String orderId;
  final String cashierId;
  final String companyId;
  final String branchId;
  final double totalAmount;
  final double discountAmount;
  final double discountPercent;
  final double finalAmount;
  final String statusId;
  final DateTime createdAt;

  // Relations
  PaymentStatus? status;
  List<PaymentDetail>? paymentDetails;
  String? cashierName;

  Payment({
    required this.id,
    required this.orderId,
    required this.cashierId,
    required this.companyId,
    required this.branchId,
    required this.totalAmount,
    this.discountAmount = 0,
    this.discountPercent = 0,
    required this.finalAmount,
    required this.statusId,
    required this.createdAt,
    this.status,
    this.paymentDetails,
    this.cashierName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: _asString(json['id']),
      orderId: _asString(json['order_id'] ?? json['orderId']),
      cashierId: _asString(json['cashier_id'] ?? json['cashierId']),
      companyId: _asString(json['company_id'] ?? json['companyId']),
      branchId: _asString(json['branch_id'] ?? json['branchId']),
      totalAmount: _asDouble(json['total_amount'] ?? json['totalAmount']),
      discountAmount: _asDouble(json['discount_amount'] ?? json['discountAmount']),
      discountPercent: _asDouble(json['discount_percent'] ?? json['discountPercent']),
      finalAmount: _asDouble(json['final_amount'] ?? json['finalAmount']),
      statusId: _asString(json['status_id'] ?? json['statusId']),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      status: json['status'] != null ? PaymentStatus.fromJson(json['status']) : null,
      paymentDetails: json['payment_details'] != null
          ? (json['payment_details'] as List)
              .map((detail) => PaymentDetail.fromJson(detail))
              .toList()
          : null,
      cashierName: json['cashier_name'] ?? json['cashierName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'cashier_id': cashierId,
      'company_id': companyId,
      'branch_id': branchId,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'discount_percent': discountPercent,
      'final_amount': finalAmount,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
      if (paymentDetails != null)
        'payment_details': paymentDetails!.map((detail) => detail.toJson()).toList(),
      if (cashierName != null) 'cashier_name': cashierName,
    };
  }

  // Helper methods
  String getStatusName() {
    return status?.name ?? 'Unknown';
  }

  bool isPending() => status?.code == 'PENDING';
  bool isConfirmed() => status?.code == 'CONFIRMED';
  bool isCancelled() => status?.code == 'CANCELLED';

  // Calculate discount amount from total
  double calculateDiscountAmount() {
    if (discountPercent > 0) {
      return totalAmount * (discountPercent / 100);
    }
    return discountAmount;
  }

  // Calculate final amount
  double calculateFinalAmount() {
    return totalAmount - calculateDiscountAmount();
  }
}

class PaymentCreateRequest {
  final int orderId;
  final double amount;
  final String paymentMethod;
  final int branchId;
  final int companyId;
  final int? cashierId;

  PaymentCreateRequest({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.branchId,
    required this.companyId,
    this.cashierId,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'amount': amount,
      'payment_method': paymentMethod,
      'branch_id': branchId,
      'company_id': companyId,
      if (cashierId != null) 'cashier_id': cashierId,
    };
  }
}

String _asString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

double _asDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString()) ?? 0.0;
}

DateTime _asDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return DateTime.now();
}
