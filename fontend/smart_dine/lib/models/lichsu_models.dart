import 'dart:convert';

class HistoryOrderModel {
  final int? id;
  final String dishName;
  final String tableNumber;
  final String staffName;
  final DateTime time;
  final String dishCategory;
  final int? orderId;
  final int? dishId;
  final int? staffId;

  HistoryOrderModel({
    this.id,
    required this.dishName,
    required this.tableNumber,
    required this.staffName,
    required this.time,
    required this.dishCategory,
    this.orderId,
    this.dishId,
    this.staffId,
  });

  // Copy with method
  HistoryOrderModel copyWith({
    int? id,
    String? dishName,
    String? tableNumber,
    String? staffName,
    DateTime? time,
    String? dishCategory,
    int? orderId,
    int? dishId,
    int? staffId,
  }) {
    return HistoryOrderModel(
      id: id ?? this.id,
      dishName: dishName ?? this.dishName,
      tableNumber: tableNumber ?? this.tableNumber,
      staffName: staffName ?? this.staffName,
      time: time ?? this.time,
      dishCategory: dishCategory ?? this.dishCategory,
      orderId: orderId ?? this.orderId,
      dishId: dishId ?? this.dishId,
      staffId: staffId ?? this.staffId,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dishName': dishName,
      'tableNumber': tableNumber,
      'staffName': staffName,
      'time': time.toIso8601String(),
      'dishCategory': dishCategory,
      'orderId': orderId,
      'dishId': dishId,
      'staffId': staffId,
    };
  }

  // From Map
  factory HistoryOrderModel.fromMap(Map<String, dynamic> map) {
    return HistoryOrderModel(
      id: map['id'] as int?,
      dishName: map['dishName'] as String? ?? '',
      tableNumber: map['tableNumber'] as String? ?? '',
      staffName: map['staffName'] as String? ?? '',
      time:
          map['time'] is String
              ? DateTime.parse(map['time'] as String)
              : map['time'] as DateTime? ?? DateTime.now(),
      dishCategory: map['dishCategory'] as String? ?? '',
      orderId: map['orderId'] as int?,
      dishId: map['dishId'] as int?,
      staffId: map['staffId'] as int?,
    );
  }

  // To JSON
  String toJson() => json.encode(toMap());

  // From JSON
  factory HistoryOrderModel.fromJson(String source) =>
      HistoryOrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  // Format time for display
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;
    return '$hour:$minute $day/$month/$year';
  }

  // Check if order is today
  bool get isToday {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }

  // Check if order is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return time.isAfter(startOfWeek) && time.isBefore(endOfWeek);
  }

  @override
  String toString() {
    return 'HistoryOrderModel(id: $id, dishName: $dishName, tableNumber: $tableNumber, staffName: $staffName, time: $time, dishCategory: $dishCategory, orderId: $orderId, dishId: $dishId, staffId: $staffId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoryOrderModel &&
        other.id == id &&
        other.dishName == dishName &&
        other.tableNumber == tableNumber &&
        other.staffName == staffName &&
        other.time == time &&
        other.dishCategory == dishCategory &&
        other.orderId == orderId &&
        other.dishId == dishId &&
        other.staffId == staffId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        dishName.hashCode ^
        tableNumber.hashCode ^
        staffName.hashCode ^
        time.hashCode ^
        dishCategory.hashCode ^
        orderId.hashCode ^
        dishId.hashCode ^
        staffId.hashCode;
  }
}
