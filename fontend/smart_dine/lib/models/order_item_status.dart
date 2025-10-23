class OrderItemStatus {
  final String id;
  final String code; // PENDING, COOKING, SERVED
  final String name;

  OrderItemStatus({required this.id, required this.code, required this.name});

  factory OrderItemStatus.fromJson(Map<String, dynamic> json) {
    return OrderItemStatus(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }

  // Helper methods cho nhân viên bếp
  bool isPending() => code == 'PENDING';
  bool isCooking() => code == 'COOKING';
  bool isServed() => code == 'SERVED';

  // Màu sắc hiển thị theo status
  String getColorCode() {
    switch (code) {
      case 'PENDING':
        return '#FFA500'; // Orange
      case 'COOKING':
        return '#FF0000'; // Red
      case 'SERVED':
        return '#00FF00'; // Green
      default:
        return '#808080'; // Gray
    }
  }
}
