import 'dart:convert';

class Payment {
  final int? id;
  final int? orderId;
  final int? cashierId;
  final int? companyId;
  final int? branchId;
  final double amount;
  final double? discountAmount;
  final double? discountPercent;
  final double? finalAmount;
  final int? statusId;
  final String? paymentMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Payment({
    this.id,
    this.orderId,
    this.cashierId,
    this.companyId,
    this.branchId,
    required this.amount,
    this.discountAmount,
    this.discountPercent,
    this.finalAmount,
    this.statusId,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Payment copyWith({
    int? id,
    int? orderId,
    int? cashierId,
    int? companyId,
    int? branchId,
    double? amount,
    double? discountAmount,
    double? discountPercent,
    double? finalAmount,
    int? statusId,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      cashierId: cashierId ?? this.cashierId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      amount: amount ?? this.amount,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      finalAmount: finalAmount ?? this.finalAmount,
      statusId: statusId ?? this.statusId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'order_id': orderId,
      'cashierId': cashierId,
      'cashier_id': cashierId,
      'companyId': companyId,
      'company_id': companyId,
      'branchId': branchId,
      'branch_id': branchId,
      'amount': amount,
      'discountAmount': discountAmount,
      'discount_amount': discountAmount,
      'discountPercent': discountPercent,
      'discount_percent': discountPercent,
      'finalAmount': finalAmount,
      'final_amount': finalAmount,
      'statusId': statusId,
      'status_id': statusId,
      'paymentMethod': paymentMethod,
      'payment_method': paymentMethod,
      'createdAt': createdAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'order_id': orderId,
      'company_id': companyId,
      'branch_id': branchId,
      'amount': amount,
      if (cashierId != null) 'cashier_id': cashierId,
      if (statusId != null) 'status_id': statusId,
      if (paymentMethod != null && paymentMethod!.isNotEmpty)
        'payment_method': paymentMethod,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: _parseInt(map['id']),
      orderId: _parseInt(map['orderId'] ?? map['order_id']),
      cashierId: _parseInt(map['cashierId'] ?? map['cashier_id']),
      companyId: _parseInt(map['companyId'] ?? map['company_id']),
      branchId: _parseInt(map['branchId'] ?? map['branch_id']),
      amount:
          _parseDouble(
            map['amount'] ?? map['final_amount'] ?? map['total_amount'],
          ) ??
          0.0,
      discountAmount: _parseDouble(
        map['discountAmount'] ?? map['discount_amount'],
      ),
      discountPercent: _parseDouble(
        map['discountPercent'] ?? map['discount_percent'],
      ),
      finalAmount: _parseDouble(map['finalAmount'] ?? map['final_amount']),
      statusId: _parseInt(map['statusId'] ?? map['status_id']),
      paymentMethod:
          map['paymentMethod']?.toString() ?? map['payment_method']?.toString(),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
      deletedAt: _parseDate(map['deletedAt'] ?? map['deleted_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Payment.fromJson(dynamic source) {
    if (source is String) {
      return Payment.fromMap(json.decode(source) as Map<String, dynamic>);
    }
    if (source is Map<String, dynamic>) {
      return Payment.fromMap(source);
    }
    throw ArgumentError('Unsupported JSON type for Payment: $source');
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    final normalized = value.toString().replaceAll(',', '');
    return double.tryParse(normalized);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }
}
