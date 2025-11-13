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
      id: json['id'],
      code: json['code'],
      name: json['name'],
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
      id: json['id'],
      code: json['code'],
      name: json['name'],
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
      paymentId: json['payment_id'],
      companyPaymentMethodId: json['company_payment_method_id'],
      amount: json['amount'].toDouble(),
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
      id: json['id'],
      orderId: json['order_id'],
      cashierId: json['cashier_id'],
      companyId: json['company_id'],
      branchId: json['branch_id'],
      totalAmount: json['total_amount'].toDouble(),
      discountAmount: json['discount_amount']?.toDouble() ?? 0,
      discountPercent: json['discount_percent']?.toDouble() ?? 0,
      finalAmount: json['final_amount'].toDouble(),
      statusId: json['status_id'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] != null ? PaymentStatus.fromJson(json['status']) : null,
      paymentDetails: json['payment_details'] != null
          ? (json['payment_details'] as List)
              .map((detail) => PaymentDetail.fromJson(detail))
              .toList()
          : null,
      cashierName: json['cashier_name'],
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
