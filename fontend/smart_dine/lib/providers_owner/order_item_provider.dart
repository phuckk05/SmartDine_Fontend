// file: providers/order_item_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/order_items.dart'; // Đảm bảo đường dẫn model đúng

// Cung cấp danh sách (phẳng) của TẤT CẢ các món trong các đơn hàng
final orderItemProvider = Provider<List<OrderItem>>((ref) {
  return [
    // --- Món cho Đơn hàng 1001 ---
    OrderItem(
      id: 1, 
      orderId: 1001, // Khớp với Order 1
      itemId: 1,     // Phở Gà
      quantity: 2, 
      note: "Không hành", 
      statusId: 3, // 3 = SERVED (Giả định)
      addedBy: 101, 
      servedBy: 101, 
      createdAt: DateTime.now()
    ),
    OrderItem(
      id: 2, 
      orderId: 1001, // Khớp với Order 1
      itemId: 3,     // Coca Cola
      quantity: 2, 
      note: "", 
      statusId: 3, 
      addedBy: 101, 
      servedBy: 101, 
      createdAt: DateTime.now()
    ),
    
    // --- Món cho Đơn hàng 1002 ---
    OrderItem(
      id: 3, 
      orderId: 1002, // Khớp với Order 2
      itemId: 2,     // Cơm Rang Dưa Bò
      quantity: 1, 
      note: "", 
      statusId: 3, 
      addedBy: 103, 
      servedBy: 103, 
      createdAt: DateTime.now()
    ),
    OrderItem(
      id: 4, 
      orderId: 1002, // Khớp với Order 2
      itemId: 4,     // Bánh Mỳ Sốt Vang
      quantity: 1, 
      note: "Nhiều sốt", 
      statusId: 3, 
      addedBy: 103, 
      servedBy: 103, 
      createdAt: DateTime.now()
    ),
    OrderItem(
      id: 5,
      orderId: 1003, // Khớp với Order 3
      itemId: 2,     // Cơm Rang Dưa Bò
      quantity: 1,
      note: "Ít cay",
      statusId: 3, // SERVED
      addedBy: 3,
      servedBy: 3,
      createdAt: DateTime.now()
    ),
     OrderItem(
      id: 6,
      orderId: 1003, // Khớp với Order 3
      itemId: 3,     // Coca Cola
      quantity: 1,
      note: "",
      statusId: 3, // SERVED
      addedBy: 3,
      servedBy: 3,
      createdAt: DateTime.now()
    ),
  ];
});