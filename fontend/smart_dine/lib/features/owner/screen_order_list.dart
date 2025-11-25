// file: screens/screen_order_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/order.dart';
import 'package:mart_dine/models_owner/payment.dart';
import 'package:mart_dine/providers_owner/order_provider.dart';
import 'package:mart_dine/providers_owner/payment_provider.dart';
import 'package:mart_dine/providers_owner/role_provider.dart'; // Lấy formatDate/formatCurrency
import 'screen_order_detail.dart';

class ScreenOrderList extends ConsumerWidget {
  // <<< THÊM: Nhận branchId >>>
  // Làm nullable (?) để màn hình này vẫn có thể dùng độc lập (hiển thị tất cả)
  final int? branchId; 

  const ScreenOrderList({super.key, this.branchId}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SỬA: Watch provider mới (FutureProvider)
    final allOrdersAsync = ref.watch(allOrdersProvider);
    final payments = ref.read(paymentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SỬA: Tiêu đề động
          Text(
            branchId == null 
              ? "Tất cả đơn hàng" 
              : "Đơn hàng của chi nhánh",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Expanded(
            // SỬA: Dùng .when để xử lý các trạng thái của FutureProvider
            child: allOrdersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Lỗi tải đơn hàng: $err")),
              data: (allOrders) {
                // Lọc danh sách theo branchId (nếu có)
                final ordersToShow = branchId == null
                    ? allOrders
                    : allOrders.where((order) => order.branchId == branchId).toList();

                if (ordersToShow.isEmpty) {
                  return const Center(child: Text("Không có đơn hàng nào."));
                }

                return ListView.builder(
                  itemCount: ordersToShow.length,
                  itemBuilder: (context, index) {
                    final order = ordersToShow[index];
                    
                    Payment? payment;
                    try {
                      payment = payments.firstWhere((p) => p.orderId == order.id);
                    } catch (e) { /*...*/ }
                    
                    final orderName = "Đơn hàng #${order.id}"; 
                    final orderDate = formatDate(order.createdAt);
                    final orderAmount = payment != null 
                                        ? formatCurrency(payment.finalAmount) 
                                        : "0 đ";
                    final orderWeek = "Tuần ${index + 1}"; // Giả lập

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScreenOrderDetail(order: order),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(orderName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(orderDate, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(orderAmount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Text(
                                    orderWeek, 
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}