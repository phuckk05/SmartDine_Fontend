import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// --- ⚠️ ACTION REQUIRED: Update these import paths ---
// Replace 'package_name' with your actual package name or relative path
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/providers/order_provider.dart';
import 'package:mart_dine/features/cashier/screen_cashier_payment.dart'; // Màn hình thanh toán
// import 'package_name/features/cashier/screen_cashier_order_detail_view.dart'; // Import nếu muốn qua chi tiết trước
// --------------------------------------------------------

class ScreenCashierPendingPayments extends ConsumerWidget {
  const ScreenCashierPendingPayments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe toàn bộ danh sách đơn hàng
    final allOrders = ref.watch(orderProvider);

    // Lọc ra các đơn hàng đang chờ thanh toán
    // CHÚ Ý: Điều kiện lọc dựa vào trạng thái bạn đặt trong `createOrderFromTable`
    // (Thường là OrderStatus.confirmed hoặc OrderStatus.newOrder/processing)
    final pendingOrders = allOrders.where((order) {
      return order.status == OrderStatus.confirmed; // Chỉ lấy các đơn đã xác nhận
             // || order.status == OrderStatus.newOrder // Bỏ comment nếu muốn lấy cả đơn mới
             // || order.status == OrderStatus.processing; // Hoặc cả đơn đang xử lý
    }).toList();

    // Sắp xếp cho các đơn hàng mới nhất lên đầu (tùy chọn)
    pendingOrders.sort((a, b) => b.orderTime.compareTo(a.orderTime));

    final currencyFormatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: Text('Yêu cầu thanh toán (${pendingOrders.length})'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        // (Bạn có thể thêm các nút actions khác nếu cần)
      ),
      body: pendingOrders.isEmpty
          ? const Center(
              child: Text(
                'Không có yêu cầu thanh toán nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      'Bàn ${order.tableName}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${order.customerCount} khách - ${order.items.length} món\nThời gian: ${DateFormat('HH:mm dd/MM/yyyy').format(order.orderTime)}',
                    ),
                    trailing: Text(
                      '${currencyFormatter.format(order.totalAmount)}đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      // ✅ Điều hướng thẳng đến màn hình thanh toán
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) =>
                              ScreenCashierPayment(orderId: order.id),
                        ),
                      );

                      /* // --- HOẶC: Điều hướng qua màn hình chi tiết trước ---
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (ctx) =>
                               ScreenCashierOrderDetailView(orderId: order.id),
                         ),
                       );
                       */
                    },
                  ),
                );
              },
            ),
    );
  }
}