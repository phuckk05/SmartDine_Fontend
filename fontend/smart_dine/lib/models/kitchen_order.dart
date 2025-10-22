import 'kitchen_order_status.dart';
import 'item.dart';
import 'user.dart';
import 'order_item.dart';
import 'order_item_status.dart';

class KitchenOrder {
  final String id;
  final String orderId;
  final String orderItemId;
  final String dishName;
  final int quantity;
  final String tableNumber;
  final String createdTime;
  final String? note;
  final KitchenOrderStatus status;
  final String? addedBy;
  final String? servedBy;
  final DateTime createdAt;

  final Item? itemDetails;
  final User? addedByUser;

  KitchenOrder({
    required this.id,
    required this.orderId,
    required this.orderItemId,
    required this.dishName,
    required this.quantity,
    required this.tableNumber,
    required this.createdTime,
    this.note,
    required this.status,
    this.addedBy,
    this.servedBy,
    required this.createdAt,
    this.itemDetails,
    this.addedByUser,
  });

  factory KitchenOrder.fromJson(Map<String, dynamic> json) {
    return KitchenOrder(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      orderItemId: json['order_item_id']?.toString() ?? '',
      dishName: json['dish_name']?.toString() ?? '',
      quantity: _parseInt(json['quantity']) ?? 0,
      tableNumber: json['table_number']?.toString() ?? '',
      createdTime: json['created_time']?.toString() ?? '',
      note: json['note']?.toString(),
      status: KitchenOrderStatus.fromString(
        json['status']?.toString() ?? 'PENDING',
      ),
      addedBy: json['added_by']?.toString(),
      servedBy: json['served_by']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      itemDetails: _parseItemDetails(json['item_details']),
      addedByUser: _parseUser(json['added_by_user']),
    );
  }

  /// Factory từ OrderItem
  factory KitchenOrder.fromOrderItem({
    required OrderItem orderItem,
    required Item item,
    required String tableNumber,
    required OrderItemStatus orderItemStatus,
    User? addedByUser,
  }) {
    return KitchenOrder(
      id: orderItem.id,
      orderId: orderItem.orderId,
      orderItemId: orderItem.id,
      dishName: item.name,
      quantity: orderItem.quantity,
      tableNumber: tableNumber,
      createdTime: _formatTime(orderItem.createdAt),
      note: orderItem.note,
      status: _mapToKitchenStatus(orderItemStatus.code),
      addedBy: orderItem.addedBy,
      servedBy: orderItem.servedBy,
      createdAt: orderItem.createdAt,
      itemDetails: item,
      addedByUser: addedByUser,
    );
  }

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_item_id': orderItemId,
      'dish_name': dishName,
      'quantity': quantity,
      'table_number': tableNumber,
      'created_time': createdTime,
      'note': note,
      'status': status.value,
      'added_by': addedBy,
      'served_by': servedBy,
      'created_at': createdAt.toIso8601String(),
      'item_details': itemDetails?.toJson(),
      'added_by_user': addedByUser?.toMap(),
    };
  }

  // ==================== BUSINESS LOGIC ====================

  bool get canBeProcessed => status == KitchenOrderStatus.pending;

  String get createdByName => addedByUser?.fullName ?? 'N/A';

  KitchenOrder markAsCompleted() {
    if (!canBeProcessed) return this;
    return copyWith(status: KitchenOrderStatus.completed);
  }

  KitchenOrder markAsOutOfStock() {
    if (!canBeProcessed) return this;
    return copyWith(status: KitchenOrderStatus.outOfStock);
  }

  KitchenOrder markAsCancelled() {
    if (!canBeProcessed) return this;
    return copyWith(status: KitchenOrderStatus.cancelled);
  }

  KitchenOrder copyWith({
    String? id,
    String? orderId,
    String? orderItemId,
    String? dishName,
    int? quantity,
    String? tableNumber,
    String? createdTime,
    String? note,
    KitchenOrderStatus? status,
    String? addedBy,
    String? servedBy,
    DateTime? createdAt,
    Item? itemDetails,
    User? addedByUser,
  }) {
    return KitchenOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderItemId: orderItemId ?? this.orderItemId,
      dishName: dishName ?? this.dishName,
      quantity: quantity ?? this.quantity,
      tableNumber: tableNumber ?? this.tableNumber,
      createdTime: createdTime ?? this.createdTime,
      note: note ?? this.note,
      status: status ?? this.status,
      addedBy: addedBy ?? this.addedBy,
      servedBy: servedBy ?? this.servedBy,
      createdAt: createdAt ?? this.createdAt,
      itemDetails: itemDetails ?? this.itemDetails,
      addedByUser: addedByUser ?? this.addedByUser,
    );
  }

  // ==================== PRIVATE HELPERS ====================

  /// Parse int safely
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse DateTime safely
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  /// Parse Item safely
  static Item? _parseItemDetails(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Map<String, dynamic>) {
        return Item.fromJson(value);
      }
      return null;
    } catch (e) {
      print('Error parsing item details: $e');
      return null;
    }
  }

  /// Parse User safely
  static User? _parseUser(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Map<String, dynamic>) {
        return User.fromMap(value);
      }
      return null;
    } catch (e) {
      print('Error parsing user: $e');
      return null;
    }
  }

  /// Format time
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Map OrderItemStatus to KitchenOrderStatus
  static KitchenOrderStatus _mapToKitchenStatus(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'PENDING':
      case 'COOKING':
        return KitchenOrderStatus.pending;
      case 'SERVED':
        return KitchenOrderStatus.completed;
      default:
        return KitchenOrderStatus.pending;
    }
  }

  // ==================== EQUALITY ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KitchenOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'KitchenOrder(id: $id, dishName: $dishName, status: ${status.displayName}, createdBy: $createdByName)';
  }
}
