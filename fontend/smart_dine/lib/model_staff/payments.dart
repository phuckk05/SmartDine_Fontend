import 'dart:convert';

// Model cho Payment theo đúng database schema
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

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['orderId'] ?? json['order_id']),
      cashierId: _parseInt(json['cashierId'] ?? json['cashier_id']),
      companyId: _parseInt(json['companyId'] ?? json['company_id']),
      branchId: _parseInt(json['branchId'] ?? json['branch_id']),
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount_amount']),
      discountPercent: _parseDouble(json['discountPercent'] ?? json['discount_percent']),
      finalAmount: _parseDouble(json['finalAmount'] ?? json['final_amount']),
      statusId: _parseInt(json['statusId'] ?? json['status_id']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'cashierId': cashierId,
      'companyId': companyId,
      'branchId': branchId,
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'discountPercent': discountPercent,
      'finalAmount': finalAmount,
      'statusId': statusId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'orderId': orderId,
      'cashierId': cashierId,
      'companyId': companyId,
      'branchId': branchId,
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'discountPercent': discountPercent,
      'finalAmount': finalAmount,
      'statusId': statusId,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
      final i = int.tryParse(value);
      if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
    }
    return DateTime.now();
  }

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

  @override
  String toString() {
    return 'Payment(id: $id, orderId: $orderId, finalAmount: $finalAmount, statusId: $statusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Model cho xu hướng doanh thu
class RevenueTrend {
  final String date;
  final double revenue;
  final int orders;

  RevenueTrend({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      date: json['date'] as String,
      revenue: _parseDouble(json['revenue']),
      orders: _parseInt(json['orders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'revenue': revenue,
      'orders': orders,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

// Model cho so sánh doanh thu
class RevenueComparison {
  final String currentPeriod;
  final double currentRevenue;
  final String previousPeriod;
  final double previousRevenue;
  final double changeAmount;
  final double changePercent;
  final bool isIncrease;

  RevenueComparison({
    required this.currentPeriod,
    required this.currentRevenue,
    required this.previousPeriod,
    required this.previousRevenue,
    required this.changeAmount,
    required this.changePercent,
    required this.isIncrease,
  });

  factory RevenueComparison.fromJson(Map<String, dynamic> json) {
    return RevenueComparison(
      currentPeriod: json['currentPeriod'] as String,
      currentRevenue: _parseDouble(json['currentRevenue']),
      previousPeriod: json['previousPeriod'] as String,
      previousRevenue: _parseDouble(json['previousRevenue']),
      changeAmount: _parseDouble(json['changeAmount']),
      changePercent: _parseDouble(json['changePercent']),
      isIncrease: json['isIncrease'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPeriod': currentPeriod,
      'currentRevenue': currentRevenue,
      'previousPeriod': previousPeriod,
      'previousRevenue': previousRevenue,
      'changeAmount': changeAmount,
      'changePercent': changePercent,
      'isIncrease': isIncrease,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

// Model cho doanh thu theo chi nhánh
class BranchRevenue {
  final int branchId;
  final double totalRevenue;
  final String startDate;
  final String endDate;

  BranchRevenue({
    required this.branchId,
    required this.totalRevenue,
    required this.startDate,
    required this.endDate,
  });

  factory BranchRevenue.fromJson(Map<String, dynamic> json) {
    return BranchRevenue(
      branchId: json['branchId'] as int,
      totalRevenue: _parseDouble(json['totalRevenue']),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'totalRevenue': totalRevenue,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}