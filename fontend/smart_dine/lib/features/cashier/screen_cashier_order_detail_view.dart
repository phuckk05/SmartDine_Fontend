import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/features/cashier/screen_cashier_payment.dart'; // Màn hình thanh toán
// import 'package:mart_dine/features/cashier/screen_final_invoice.dart'; // Tạm thời chưa cần đến đây từ nút này
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/providers/order_provider.dart';

class ScreenCashierOrderDetailView extends ConsumerWidget {
  final String orderId;

  const ScreenCashierOrderDetailView({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider.notifier).getOrderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
        body: const Center(child: Text('Không tìm thấy đơn hàng.')),
      );
    }

    final currencyFormatter = NumberFormat('#,###', 'vi_VN');
    final isOrderPaid = order.status == OrderStatus.paid;
    final isOrderCancelled = order.status == OrderStatus.cancelled;

    // Trạng thái hiển thị
    String statusText;
    Color statusColor;
    if (isOrderPaid) {
      statusText = 'Đã thanh toán';
      statusColor = Colors.green;
    } else if (isOrderCancelled) {
      statusText = 'Đã hủy';
      statusColor = Colors.red;
    } else {
      statusText = 'Đang xử lý';
      statusColor = Colors.orange[700]!;
    }

    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng toàn bộ
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Chi Tiết Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Padding dưới để không che nút
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Căn trên cùng
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bàn ${order.tableName}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.customerCount} khách - ${DateFormat('HH:mm dd/MM/yyyy').format(order.orderTime)}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1), // Nền nhạt hơn cho trạng thái
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Trạng thái: $statusText',
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Khung chứa danh sách món ăn
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [ // Thêm shadow nhẹ
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách món ăn',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...order.items.map((dish) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'x1 ${dish.name}', // Số lượng tạm thời là 1
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      if (dish.note != null && dish.note!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            '(${dish.note})',
                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${currencyFormatter.format(dish.price)}đ',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 24, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng tiền:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${currencyFormatter.format(order.totalAmount)} VND',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nút cố định ở dưới màn hình
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    // ✅ NÚT NÀY BÂY GIỜ LÀ NÚT THANH TOÁN
                    child: ElevatedButton(
                      onPressed: isOrderPaid || isOrderCancelled ? null : () { // Chỉ nhấn được khi chưa thanh toán và chưa hủy
                         // Điều hướng đến màn hình thanh toán
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (ctx) => ScreenCashierPayment(orderId: orderId))
                         );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOrderPaid || isOrderCancelled ? Colors.grey[400] : Colors.blueAccent, // Xanh khi kích hoạt
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Thanh Toán'), // ✅ Đổi tên nút
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isOrderPaid || isOrderCancelled ? null : () { // Chỉ hủy khi chưa thanh toán và chưa bị hủy
                        _showCancelPaymentDialog(context, ref, orderId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOrderPaid || isOrderCancelled ? Colors.grey[400] : Colors.red[400], // Màu đỏ khi kích hoạt
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hủy Yêu Cầu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // ✅ XÓA FloatingActionButton
      // floatingActionButton: !isOrderPaid && order.status != OrderStatus.cancelled ? FloatingActionButton.extended(...) : null,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Dialog xác nhận hủy thanh toán
  void _showCancelPaymentDialog(BuildContext context, WidgetRef ref, String orderId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bạn có chắc chắn muốn hủy yêu cầu thanh toán không?'),
        content: const Text('Thao tác này sẽ hủy đơn hàng và không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Không', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(orderProvider.notifier).updateOrder(orderId, status: OrderStatus.cancelled); // Cập nhật trạng thái thành 'cancelled'
              Navigator.pop(dialogContext); // Đóng dialog
              // Không pop màn hình này nữa, để người dùng thấy trạng thái đã hủy
              // Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã hủy yêu cầu thanh toán.'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            child: const Text('Có', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}