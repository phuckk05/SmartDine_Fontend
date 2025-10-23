import 'dart:ui';

import 'kitchen_order.dart';
import 'user.dart';

enum NotificationType {
  newOrder, // Món mới
  orderReady, // Món đã xong
  orderOutOfStock, // Món hết
  orderCancelled, // Món bị hủy
  orderPickedUp, // Món đã được lấy
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.newOrder:
        return 'Món mới';
      case NotificationType.orderReady:
        return 'Món đã xong';
      case NotificationType.orderOutOfStock:
        return 'Món hết';
      case NotificationType.orderCancelled:
        return 'Món bị hủy';
      case NotificationType.orderPickedUp:
        return 'Món đã lấy';
    }
  }

  String get actionText {
    switch (this) {
      case NotificationType.newOrder:
        return 'Xác Nhận Làm Món';
      case NotificationType.orderReady:
        return 'Món Hết Nguyên Liệu';
      case NotificationType.orderOutOfStock:
        return 'Thông Báo Đã Hết';
      case NotificationType.orderCancelled:
        return 'Đã Hủy';
      case NotificationType.orderPickedUp:
        return 'Đã Lấy';
    }
  }

  String get secondaryActionText {
    switch (this) {
      case NotificationType.newOrder:
        return 'Món Hết Nguyên Liệu';
      case NotificationType.orderReady:
        return 'Xác Nhận Lấy Món';
      default:
        return '';
    }
  }

  Color getActionColor() {
    switch (this) {
      case NotificationType.newOrder:
        return const Color(0xFF2196F3); // Blue
      case NotificationType.orderReady:
        return const Color(0xFFFF9800); // Orange
      case NotificationType.orderOutOfStock:
        return const Color(0xFF9E9E9E); // Grey
      case NotificationType.orderCancelled:
        return const Color(0xFF9E9E9E); // Grey
      case NotificationType.orderPickedUp:
        return const Color(0xFF4CAF50); // Green
    }
  }

  Color getSecondaryActionColor() {
    switch (this) {
      case NotificationType.newOrder:
        return const Color(0xFFFF9800); // Orange
      case NotificationType.orderReady:
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

class OrderNotification {
  final String id;
  final String orderId;
  final String dishName;
  final String tableNumber;
  final String createdTime;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? note;

  // Chi tiết
  final KitchenOrder? orderDetails;
  final User? actionBy;

  OrderNotification({
    required this.id,
    required this.orderId,
    required this.dishName,
    required this.tableNumber,
    required this.createdTime,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.note,
    this.orderDetails,
    this.actionBy,
  });

  /// Tạo từ KitchenOrder
  factory OrderNotification.fromKitchenOrder({
    required KitchenOrder order,
    required NotificationType type,
    User? actionBy,
  }) {
    return OrderNotification(
      id: 'notif-${order.id}',
      orderId: order.orderId,
      dishName: order.dishName,
      tableNumber: order.tableNumber,
      createdTime: order.createdTime,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      note: order.note,
      orderDetails: order,
      actionBy: actionBy,
    );
  }

  factory OrderNotification.fromJson(Map<String, dynamic> json) {
    return OrderNotification(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      dishName: json['dish_name']?.toString() ?? '',
      tableNumber: json['table_number']?.toString() ?? '',
      createdTime: json['created_time']?.toString() ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.newOrder,
      ),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      note: json['note']?.toString(),
      orderDetails:
          json['order_details'] != null
              ? KitchenOrder.fromJson(json['order_details'])
              : null,
      actionBy:
          json['action_by'] != null ? User.fromMap(json['action_by']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'dish_name': dishName,
      'table_number': tableNumber,
      'created_time': createdTime,
      'type': type.name,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'note': note,
      'order_details': orderDetails?.toJson(),
      'action_by': actionBy?.toMap(),
    };
  }

  OrderNotification markAsRead() {
    return copyWith(isRead: true);
  }

  OrderNotification copyWith({
    String? id,
    String? orderId,
    String? dishName,
    String? tableNumber,
    String? createdTime,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    String? note,
    KitchenOrder? orderDetails,
    User? actionBy,
  }) {
    return OrderNotification(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      dishName: dishName ?? this.dishName,
      tableNumber: tableNumber ?? this.tableNumber,
      createdTime: createdTime ?? this.createdTime,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      orderDetails: orderDetails ?? this.orderDetails,
      actionBy: actionBy ?? this.actionBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderNotification(id: $id, dishName: $dishName, type: ${type.displayName})';
  }
}
