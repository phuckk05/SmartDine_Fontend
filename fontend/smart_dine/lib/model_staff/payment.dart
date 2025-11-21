class Payment {
  final int orderId;
  final double amount;
  final String paymentMethod;
  final int branchId;
  final int companyId;
  final int? cashierId;

  Payment({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.branchId,
    required this.companyId,
    this.cashierId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      orderId: _parseInt(json['orderId'] ?? json['order_id']),
      amount: _parseDouble(json['amount']),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? '',
      branchId: _parseInt(json['branchId'] ?? json['branch_id']),
      companyId: _parseInt(json['companyId'] ?? json['company_id']),
      cashierId: _parseNullableInt(json['cashierId'] ?? json['cashier_id']),
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
      if (cashierId != null) 'cashierId': cashierId,
    };
  }

  Map<String, dynamic> toCreatePayload() {
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

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
