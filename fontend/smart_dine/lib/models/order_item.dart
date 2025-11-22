class OrderItem {
  // SỬA TẤT CẢ CÁC ID TỪ String SANG int
  int? id;
  final int orderId;
  final int itemId;
  final int quantity;
  final String? note;
  final int statusId;
  final int? addedBy;
  final int? servedBy;
  final DateTime createdAt;

  OrderItem({
    this.id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    this.note,
    required this.statusId,
    this.addedBy,
    this.servedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Robust parsers
  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _parseNullableInt(dynamic v) {
    if (v == null || (v is String && v.trim().isEmpty)) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
      final i = int.tryParse(v);
      if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
    }
    return DateTime.now();
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: _parseInt(map['id']),
      orderId: _parseInt(map['order_id'] ?? map['orderId']),
      itemId: _parseInt(map['item_id'] ?? map['itemId']),
      quantity: _parseInt(map['quantity'] ?? map['qty']),
      note: map['note']?.toString(),
      statusId: _parseInt(map['status_id'] ?? map['statusId']),
      addedBy: _parseNullableInt(map['added_by'] ?? map['addedBy']),
      servedBy: _parseNullableInt(map['served_by'] ?? map['servedBy']),
      createdAt: _parseDate(
        map['created_at'] ?? map['createdAt'] ?? map['created'],
      ),
    );
  }
  factory OrderItem.create({
    required int orderId,
    required int itemId,
    required int quantity,
    String? note,
    required int statusId,
    int? addedBy,
    int? servedBy,
    required DateTime createdAt,
  }) {
    //

    return OrderItem(
      orderId: orderId,
      itemId: itemId,
      quantity: quantity,
      note: note,
      statusId: statusId,
      addedBy: addedBy,
      servedBy: servedBy,
      createdAt: createdAt,
    );
  }
  // HÀM PARSE AN TOÀN (RẤT QUAN TRỌNG)
  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _asIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  // static DateTime _parseDate(dynamic value) {
  //   if (value == null) {
  //     return DateTime.now(); // Trả về ngày giờ hiện tại nếu null
  //   }
  //   if (value is DateTime) return value;
  //   return DateTime.tryParse(value.toString()) ?? DateTime.now();
  // }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _asInt(json['id']),
      orderId: _asInt(json['order_id']),
      itemId: _asInt(json['item_id']),
      quantity: _asInt(json['quantity']),
      note: json['note']?.toString(),
      statusId: _asInt(json['status_id']),
      addedBy: _asIntNullable(json['added_by']),
      servedBy: _asIntNullable(json['served_by']),
      createdAt: _parseDate(json['created_at']), // Dùng hàm parse an toàn
    );
  }
  //From Map
  // factory OrderItem.fromMap(Map<String, dynamic> map) {
  //   return OrderItem(
  //     id: _asInt(map['id']),
  //     orderId: _asInt(map['order_id']),
  //     itemId: _asInt(map['item_id']),
  //     quantity: _asInt(map['quantity']),
  //     note: map['note']?.toString(),
  //     statusId: _asInt(map['status_id']),
  //     addedBy: _asIntNullable(map['createby'] ?? map['added_by']),
  //     servedBy: _asIntNullable(map['added__by'] ?? map['served_by']),
  //     createdAt: _parseDate(map['servedd_at'] ?? map['created_at']),
  //   );
  // }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'order_id': orderId,
  //     'item_id': itemId,
  //     'quantity': quantity,
  //     'note': note,
  //     'status_id': statusId,
  //     'added__by': servedBy,
  //     'createby': addedBy,
  //     'servedd_at': createdAt.toIso8601String(),
  //   };
  // }

  // factory OrderItem.fromJson(String source) =>
  //     OrderItem.fromMap(json.decode(source));

  // String toJson() => json.encode(toMap());
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'itemId': itemId,
      'quantity': quantity,
      'note': note,
      'statusId': statusId,
      'addedBy': addedBy,
      'servedBy': servedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'orderId': orderId,
      'itemId': itemId,
      'quantity': quantity,
      if (note != null && note!.isNotEmpty) 'note': note,
      'statusId': statusId,
      if (addedBy != null) 'addedBy': addedBy,
      if (servedBy != null) 'servedBy': servedBy,
    };
  }

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? itemId,
    int? quantity,
    String? note,
    int? statusId,
    int? addedBy,
    int? servedBy,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      statusId: statusId ?? this.statusId,
      addedBy: addedBy ?? this.addedBy,
      servedBy: servedBy ?? this.servedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'OrderItem(id: $id, orderId: $orderId, itemId: $itemId, qty: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
