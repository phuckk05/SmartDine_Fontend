import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/models/order.dart'; // Import OrderModel với OrderStatus
import 'package:mart_dine/providers/order_provider.dart';

class ScreenCashierNotifications extends ConsumerWidget {
  const ScreenCashierNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(orderProvider);

    // ✅ Lọc các đơn hàng đã được nhân viên xác nhận (trạng thái là 'confirmed')
    final List<OrderModel> confirmedOrders = allOrders
        .where((order) => order.status == OrderStatus.confirmed) // Chỉ lấy đơn hàng đã xác nhận
        .toList();

    // Sắp xếp đơn hàng mới nhất lên đầu
    confirmedOrders.sort((a, b) => b.orderTime.compareTo(a.orderTime));

    final currencyFormatter = NumberFormat('#,###', 'vi_VN');
    final timeFormatter = DateFormat('HH:mm dd/MM/yyyy', 'vi_VN');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Danh sách Thông báo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đơn hàng đã xác nhận', // Tiêu đề được cập nhật
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: confirmedOrders.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có đơn hàng nào được xác nhận gần đây.', // Thông báo khi trống
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: confirmedOrders.length,
                      itemBuilder: (context, index) {
                        final order = confirmedOrders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[50], // Nền màu xanh nhạt cho thông báo đã xác nhận
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline, size: 28, color: Colors.blue[700]), // Icon xác nhận
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Đơn hàng ${order.tableName} đã xác nhận', // Loại thông báo
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Tổng giá: ${currencyFormatter.format(order.totalAmount)} VNĐ'),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeFormatter.format(order.orderTime),
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}