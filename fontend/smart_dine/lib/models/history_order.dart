import 'kitchen_order.dart';
import 'user.dart';
import 'item.dart';

class HistoryOrder {
  final String id;
  final String orderId;
  final String dishName;
  final int quantity;
  final String tableNumber;
  final String staffName;
  final String staffId;
  final DateTime servedAt;
  final DateTime orderCreatedAt;
  final String? note;

  // Chi tiết
  final Item? itemDetails;
  final User? servedByUser;

  HistoryOrder({
    required this.id,
    required this.orderId,
    required this.dishName,
    required this.quantity,
    required this.tableNumber,
    required this.staffName,
    required this.staffId,
    required this.servedAt,
    required this.orderCreatedAt,
    this.note,
    this.itemDetails,
    this.servedByUser,
  });

  /// Format thời gian hiển thị
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(servedAt);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${servedAt.day}/${servedAt.month}/${servedAt.year} ${servedAt.hour}:${servedAt.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Format ngày đầy đủ
  String get fullFormattedDate {
    return '${servedAt.day.toString().padLeft(2, '0')}/${servedAt.month.toString().padLeft(2, '0')}/${servedAt.year} ${servedAt.hour.toString().padLeft(2, '0')}:${servedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Tạo từ KitchenOrder
  factory HistoryOrder.fromKitchenOrder({
    required KitchenOrder order,
    required User servedByUser,
    required DateTime servedAt,
  }) {
    return HistoryOrder(
      id: order.id,
      orderId: order.orderId,
      dishName: order.dishName,
      quantity: order.quantity,
      tableNumber: order.tableNumber,
      staffName: servedByUser.fullName,
      staffId: servedByUser.id?.toString() ?? '',
      servedAt: servedAt,
      orderCreatedAt: order.createdAt,
      note: order.note,
      itemDetails: order.itemDetails,
      servedByUser: servedByUser,
    );
  }

  factory HistoryOrder.fromJson(Map<String, dynamic> json) {
    return HistoryOrder(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      dishName: json['dish_name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      tableNumber: json['table_number']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      staffId: json['staff_id']?.toString() ?? '',
      servedAt:
          DateTime.tryParse(json['served_at']?.toString() ?? '') ??
          DateTime.now(),
      orderCreatedAt:
          DateTime.tryParse(json['order_created_at']?.toString() ?? '') ??
          DateTime.now(),
      note: json['note']?.toString(),
      itemDetails:
          json['item_details'] != null
              ? Item.fromJson(json['item_details'] as Map<String, dynamic>)
              : null,
      servedByUser:
          json['served_by_user'] != null
              ? User.fromMap(json['served_by_user'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'dish_name': dishName,
      'quantity': quantity,
      'table_number': tableNumber,
      'staff_name': staffName,
      'staff_id': staffId,
      'served_at': servedAt.toIso8601String(),
      'order_created_at': orderCreatedAt.toIso8601String(),
      'note': note,
      'item_details': itemDetails?.toJson(),
      'served_by_user': servedByUser?.toMap(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HistoryOrder(id: $id, dishName: $dishName, staffName: $staffName, servedAt: $servedAt)';
  }
}
