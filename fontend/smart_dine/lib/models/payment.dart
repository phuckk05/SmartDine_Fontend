import 'dart:convert';

class Payment {
  final int orderId;
  final double amount;
  final String paymentMethod;
  final int branchId;
  final int companyId;

  Payment({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.branchId,
    required this.companyId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      orderId: json['orderId'] ?? json['order_id'] ?? 0,
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? '',
      branchId: json['branchId'] ?? json['branch_id'] ?? 0,
      companyId: json['companyId'] ?? json['company_id'] ?? 0,
    );
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'branchId': branchId,
      'companyId': companyId,
    };
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'branchId': branchId,
      'companyId': companyId,
    };
  }
}
