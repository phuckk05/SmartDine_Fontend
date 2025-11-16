// file: models/payment.dart
import 'dart:convert';

class Payment {
  final int id;
  final int orderId;
  final int cashierId;
  final int companyId;
  final int branchId;
  final double totalAmount;
  final double discountAmount;
  final double discountPercent;
  final double finalAmount;
  final int statusId;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.cashierId,
    required this.companyId,
    required this.branchId,
    required this.totalAmount,
    required this.discountAmount,
    required this.discountPercent,
    required this.finalAmount,
    required this.statusId,
    required this.createdAt,
  });

  Payment copyWith({
    int? id,
    int? orderId,
    int? cashierId,
    int? companyId,
    int? branchId,
    double? totalAmount,
    double? discountAmount,
    double? discountPercent,
    double? finalAmount,
    int? statusId,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      cashierId: cashierId ?? this.cashierId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      finalAmount: finalAmount ?? this.finalAmount,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
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
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: int.tryParse(map['id'].toString()) ?? 0,
      orderId: int.tryParse(map['order_id'].toString()) ?? 0,
      cashierId: int.tryParse(map['cashier_id'].toString()) ?? 0,
      companyId: int.tryParse(map['company_id'].toString()) ?? 0,
      branchId: int.tryParse(map['branch_id'].toString()) ?? 0,
      totalAmount: double.tryParse(map['total_amount'].toString()) ?? 0.0,
      discountAmount: double.tryParse(map['discount_amount'].toString()) ?? 0.0,
      discountPercent:
          double.tryParse(map['discount_percent'].toString()) ?? 0.0,
      finalAmount: double.tryParse(map['final_amount'].toString()) ?? 0.0,
      statusId: int.tryParse(map['status_id'].toString()) ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Payment.fromJson(String source) =>
      Payment.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Payment(id: $id, orderId: $orderId, cashierId: $cashierId, companyId: $companyId, branchId: $branchId, totalAmount: $totalAmount, discountAmount: $discountAmount, discountPercent: $discountPercent, finalAmount: $finalAmount, statusId: $statusId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Payment &&
        other.id == id &&
        other.orderId == orderId &&
        other.cashierId == cashierId &&
        other.companyId == companyId &&
        other.branchId == branchId &&
        other.totalAmount == totalAmount &&
        other.discountAmount == discountAmount &&
        other.discountPercent == discountPercent &&
        other.finalAmount == finalAmount &&
        other.statusId == statusId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderId.hashCode ^
        cashierId.hashCode ^
        companyId.hashCode ^
        branchId.hashCode ^
        totalAmount.hashCode ^
        discountAmount.hashCode ^
        discountPercent.hashCode ^
        finalAmount.hashCode ^
        statusId.hashCode ^
        createdAt.hashCode;
  }
}