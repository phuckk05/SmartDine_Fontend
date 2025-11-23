// file: providers/payment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/payment.dart'; // Đảm bảo đường dẫn model đúng

// Cung cấp danh sách TẤT CẢ các thanh toán
final paymentProvider = Provider<List<Payment>>((ref) {
  return [
    // Thanh toán cho Order 1001
    Payment(
      id: 1,
      orderId: 1001, // Khớp với Order 1
      cashierId: 101, // Nguyễn Đình Phúc
      companyId: 1,
      branchId: 101,
      totalAmount: 130000, // (50k*2 + 15k*2)
      discountAmount: 0,
      discountPercent: 0,
      finalAmount: 130000,
      statusId: 2, // 2 = CONFIRMED (Giả định)
      createdAt: DateTime(2025, 3, 26, 12, 45),
    ),
    // Thanh toán cho Order 1002
     Payment(
      id: 2,
      orderId: 1002, // Khớp với Order 2
      cashierId: 103, // Anh D
      companyId: 1,
      branchId: 101,
      totalAmount: 100000, // (45k*1 + 55k*1)
      discountAmount: 10000, // Giảm 10k
      discountPercent: 0,
      finalAmount: 90000,
      statusId: 2, 
      createdAt: DateTime(2025, 3, 25, 18, 20),
    ),
    Payment(
      id: 3,
      orderId: 1003, // Khớp Order 3
      cashierId: 3, // Trần Thị D
      companyId: 1,
      branchId: 103, // Chi nhánh C
      totalAmount: 60000, // (45k*1 + 15k*1)
      discountAmount: 0,
      discountPercent: 0,
      finalAmount: 60000,
      statusId: 2, // CONFIRMED
      createdAt: DateTime(2025, 10, 22, 10, 15),
    ),
  ];
});