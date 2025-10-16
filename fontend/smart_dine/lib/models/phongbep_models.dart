import 'dart:convert';

/// Enum cho trạng thái đơn hàng
enum OrderStatus {
  pending('pending', 'Chưa làm'),
  completed('completed', 'Đã làm'),
  outOfStock('out_of_stock', 'Hết món'),
  cancelled('cancelled', 'Đã hủy');

  final String value;
  final String displayName;

  const OrderStatus(this.value, this.displayName);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Model cho đơn hàng phòng bếp
class KitchenOrder {
  final int? id;
  final String dishName;
  final String createdTime;
  final String tableNumber;
  final OrderStatus status;
  final bool isPickedUp;
  final DateTime createdAt;
  final DateTime updatedAt;

  KitchenOrder({
    this.id,
    required this.dishName,
    required this.createdTime,
    required this.tableNumber,
    required this.status,
    this.isPickedUp = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Factory constructor để tạo order mới
  factory KitchenOrder.create({
    required String dishName,
    required String createdTime,
    required String tableNumber,
    OrderStatus status = OrderStatus.pending,
  }) {
    final now = DateTime.now();
    return KitchenOrder(
      dishName: dishName,
      createdTime: createdTime,
      tableNumber: tableNumber,
      status: status,
      isPickedUp: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Copy with - tạo bản sao với một số thuộc tính thay đổi
  KitchenOrder copyWith({
    int? id,
    String? dishName,
    String? createdTime,
    String? tableNumber,
    OrderStatus? status,
    bool? isPickedUp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KitchenOrder(
      id: id ?? this.id,
      dishName: dishName ?? this.dishName,
      createdTime: createdTime ?? this.createdTime,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      isPickedUp: isPickedUp ?? this.isPickedUp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Chuyển sang Map để lưu trữ hoặc gửi API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dishName': dishName,
      'createdTime': createdTime,
      'tableNumber': tableNumber,
      'status': status.value,
      'isPickedUp': isPickedUp,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Tạo object từ Map
  factory KitchenOrder.fromMap(Map<String, dynamic> map) {
    return KitchenOrder(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      dishName: map['dishName']?.toString() ?? '',
      createdTime: map['createdTime']?.toString() ?? '',
      tableNumber: map['tableNumber']?.toString() ?? '',
      status: OrderStatus.fromString(map['status']?.toString() ?? 'pending'),
      isPickedUp: map['isPickedUp'] == true,
      createdAt:
          map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  /// Chuyển sang JSON string
  String toJson() => json.encode(toMap());

  /// Tạo object từ JSON string
  factory KitchenOrder.fromJson(String source) =>
      KitchenOrder.fromMap(json.decode(source));

  /// Đánh dấu order đã hoàn thành
  KitchenOrder markAsCompleted() {
    return copyWith(
      status: OrderStatus.completed,
      isPickedUp: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Đánh dấu order đã hết món
  KitchenOrder markAsOutOfStock() {
    return copyWith(status: OrderStatus.outOfStock, updatedAt: DateTime.now());
  }

  /// Đánh dấu order đã hủy
  KitchenOrder markAsCancelled() {
    return copyWith(status: OrderStatus.cancelled, updatedAt: DateTime.now());
  }

  /// Đánh dấu order đã được lấy
  KitchenOrder markAsPickedUp() {
    return copyWith(isPickedUp: true, updatedAt: DateTime.now());
  }

  /// Kiểm tra order có thể xử lý được không (chỉ pending mới xử lý được)
  bool get canBeProcessed => status == OrderStatus.pending;

  /// Kiểm tra order đang chờ lấy không
  bool get isWaitingForPickup => status == OrderStatus.completed && !isPickedUp;

  @override
  String toString() {
    return 'KitchenOrder(id: $id, dishName: $dishName, createdTime: $createdTime, tableNumber: $tableNumber, status: ${status.value}, isPickedUp: $isPickedUp, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KitchenOrder &&
        other.id == id &&
        other.dishName == dishName &&
        other.createdTime == createdTime &&
        other.tableNumber == tableNumber &&
        other.status == status &&
        other.isPickedUp == isPickedUp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        dishName.hashCode ^
        createdTime.hashCode ^
        tableNumber.hashCode ^
        status.hashCode ^
        isPickedUp.hashCode;
  }
}
