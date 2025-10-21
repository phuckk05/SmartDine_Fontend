import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// Import màn hình xem chi tiết
import 'package:mart_dine/features/cashier/screen_cashier_order_detail_view.dart';
// Import màn hình thông báo của Thu ngân
import 'package:mart_dine/features/cashier/screen_cashier_notifications.dart';
// ✅ Import màn hình BÁO CÁO của Thu ngân
import 'package:mart_dine/features/cashier/screen_cashier_report.dart';
// import 'package:mart_dine/features/cashier/screen_cashier_settings.dart'; // Nếu có màn hình cài đặt
import 'package:mart_dine/providers/order_provider.dart';
import 'package:mart_dine/models/order.dart';

class ScreenCashierHome extends ConsumerWidget {
  const ScreenCashierHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe danh sách đơn hàng từ provider
    // Lọc ra những đơn hàng chưa được thanh toán (paymentMethod == null VÀ isPaid == false)
    final pendingOrders = ref.watch(orderProvider).where((order) => order.paymentMethod == null && !order.isPaid).toList();

    // Sắp xếp đơn hàng mới nhất lên đầu
    pendingOrders.sort((a, b) => b.orderTime.compareTo(a.orderTime));

    final currencyFormatter = NumberFormat('#,###', 'vi_VN');
    final timeFormatter = DateFormat('HH:mm - dd/MM', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách hóa đơn', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          // ✅ NÚT BÁO CÁO MỚI
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const ScreenCashierReport()),
              );
            },
            icon: const Icon(Icons.bar_chart), // Icon biểu đồ cột
            tooltip: 'Báo cáo',
          ),
          // Nút Thông báo
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const ScreenCashierNotifications()),
              );
            },
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Thông báo',
          ),
          // Nút Cài đặt (nếu có)
          IconButton(
            onPressed: () {
              // TODO: Điều hướng đến màn hình cài đặt của Thu ngân
              // Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ScreenCashierSettings()));
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Cài đặt',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pendingOrders.isEmpty
          ? const Center(
              child: Text(
                'Chưa có đơn hàng nào cần thanh toán.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Điều hướng đến màn hình XEM CHI TIẾT
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => ScreenCashierOrderDetailView(orderId: order.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.tableName, // Hiển thị tên bàn
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container( // Nút trạng thái "Chưa xử lý"
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(6)
                                ),
                                child: Text(
                                  'Chưa xử lý',
                                  style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${order.customerCount} khách - ${timeFormatter.format(order.orderTime)}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng cộng:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${currencyFormatter.format(order.totalAmount)} VND',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}