import 'package:flutter/foundation.dart'; // Để dùng ValueGetter
import 'package:uuid/uuid.dart'; // Đảm bảo đã thêm uuid vào pubspec.yaml
import 'dish.dart'; // Giả định DishModel của bạn nằm ở đây

// Enum cho các phương thức thanh toán
enum OrderPaymentMethod {
  cash,
  qrCode,
  creditCard,
}

// ✅ MỚI: Enum cho trạng thái đơn hàng
enum OrderStatus {
  newOrder,       // Đơn hàng mới tạo (ví dụ: nhân viên vừa nhập món)
  confirmed,      // Nhân viên đã xác nhận đơn hàng (sẵn sàng thanh toán / gửi bếp)
  preparing,      // Bếp đang chuẩn bị (tùy chọn)
  readyForServe,  // Món ăn đã sẵn sàng phục vụ (tùy chọn)
  served,         // Đã phục vụ (tùy chọn)
  paid,           // Đã thanh toán
  cancelled,      // Đã hủy
}

class OrderModel {
  final String id;
  final String tableName; // Tên bàn
  final String tableId; // ID của bàn liên kết
  final int customerCount; // Số lượng khách
  final List<DishModel> items; // Danh sách món ăn đã order
  final double totalAmount; // Tổng số tiền
  final DateTime orderTime; // Thời gian đặt hàng
  final OrderPaymentMethod? paymentMethod; // Phương thức thanh toán (null nếu chưa thanh toán)
  final OrderStatus status; // ✅ TRƯỜNG MỚI: Trạng thái của đơn hàng

  OrderModel({
    String? id,
    required this.tableName,
    required this.tableId,
    required this.customerCount,
    this.items = const [],
    required this.totalAmount,
    required this.orderTime,
    this.paymentMethod,
    this.status = OrderStatus.newOrder, // ✅ Mặc định là đơn hàng mới tạo
  }) : id = id ?? const Uuid().v4();

  // Getter để kiểm tra đã thanh toán hay chưa, dựa vào trạng thái
  bool get isPaid => status == OrderStatus.paid;

  // Phương thức copyWith để tạo OrderModel mới với các trường được thay đổi
  OrderModel copyWith({
    String? id,
    String? tableName,
    String? tableId,
    int? customerCount,
    List<DishModel>? items,
    double? totalAmount,
    DateTime? orderTime,
    ValueGetter<OrderPaymentMethod?>? paymentMethod,
    OrderStatus? status, // ✅ Thêm status vào copyWith
  }) {
    return OrderModel(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      tableId: tableId ?? this.tableId,
      customerCount: customerCount ?? this.customerCount,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderTime: orderTime ?? this.orderTime,
      paymentMethod: paymentMethod != null ? paymentMethod() : this.paymentMethod,
      status: status ?? this.status, // ✅ Cập nhật trạng thái
    );
  }

  // toMap và fromJson cũng cần được cập nhật để bao gồm trường 'status'
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      tableName: json['tableName'] as String,
      tableId: json['tableId'] as String,
      customerCount: json['customerCount'] as int,
      items: (json['items'] as List<dynamic>?)
          ?.map((itemJson) => DishModel.fromJson(itemJson as Map<String, dynamic>))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderTime: DateTime.parse(json['orderTime'] as String),
      paymentMethod: json['paymentMethod'] != null
          ? OrderPaymentMethod.values.firstWhere(
              (e) => e.toString().split('.').last == json['paymentMethod'],
              orElse: () => OrderPaymentMethod.cash,
            )
          : null,
      status: OrderStatus.values.firstWhere( // ✅ Parse trường status
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.newOrder, // Mặc định nếu không tìm thấy
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableName': tableName,
      'tableId': tableId,
      'customerCount': customerCount,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderTime': orderTime.toIso8601String(),
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'status': status.toString().split('.').last, // ✅ Thêm status vào map
    };
  }
}