// file: screens/screen_order_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/order.dart';
import 'package:mart_dine/models_owner/order_items.dart';
import 'package:mart_dine/models_owner/item.dart';
import 'package:mart_dine/models_owner/payment.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/providers_owner/order_item_provider.dart';
import 'package:mart_dine/providers_owner/item_provider.dart';
import 'package:mart_dine/providers_owner/payment_provider.dart';
import 'package:mart_dine/providers_owner/mock_user_provider.dart'; // (Giả định tệp này tồn tại)
import 'package:mart_dine/providers_owner/role_provider.dart'; // Import helper

// SỬA: Chuyển thành ConsumerWidget
class ScreenOrderDetail extends ConsumerWidget {
  // SỬA: Yêu cầu Order object
  final Order order;

  const ScreenOrderDetail({super.key, required this.order});

  // SỬA: Bỏ các hàm helper cũ
  // String _getValue(String key, {String defaultValue = 'N/A'}) { ... }
  Color _getStatusColor(int statusId) {
    // Giả định 4 = Paid (Green), ngược lại là Red
    return statusId == 4 ? Colors.green : Colors.red;
  }
  String _getStatusName(int statusId) {
    return statusId == 4 ? "Đã trả" : "Chưa trả";
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SỬA: Lấy dữ liệu từ các provider
    final allOrderItems = ref.watch(orderItemProvider);
    final allItemsAsync = ref.watch(allItemsProvider); // SỬA LỖI: Dùng provider đúng
    final allUsers = ref.watch(mockUserListProvider);
    final allPayments = ref.watch(paymentProvider);

    // SỬA: Lọc dữ liệu cho đơn hàng này
    final thisOrderItems = allOrderItems.where((oi) => oi.orderId == order.id).toList();
    
    // Tìm Payment
    Payment? thisPayment;
    try {
      thisPayment = allPayments.firstWhere((p) => p.orderId == order.id);
    } catch (e) {
      //
    }
    
    // Tìm Tên nhân viên
    String staffName = "Không rõ";
    try {
      staffName = allUsers.firstWhere((u) => u.id == order.userId).fullName;
    } catch (e) {
      //
    }
    
    // Lấy tên bàn (Giả lập)
    final tableName = "Bàn ${order.tableId}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chi tiết đơn",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Chi nhánh A", // Giữ giả lập
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("Mã HD : ${order.id}",
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      Text("Tạo ngày : ${formatDate(order.createdAt)}",
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  // Trạng thái thanh toán
                  Container(
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.statusId),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      _getStatusName(order.statusId),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              const Divider(thickness: 1),
              const SizedBox(height: 10),

              // Thông tin bàn
              const Text("Thông tin bàn",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              _detailRow("Bàn", tableName, isBoldValue: true),
              _detailRow("Nhân viên phục vụ", staffName, isBoldValue: true),

              const SizedBox(height: 15),
              const Text("Danh sách món",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),

              // SỬA: Xử lý trạng thái của allItemsProvider
              allItemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Lỗi tải món ăn: $err')),
                data: (allItems) {
                  return ListView.builder(
                    shrinkWrap: true, // Quan trọng khi lồng ListView
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: thisOrderItems.length,
                    itemBuilder: (context, index) {
                      final orderItem = thisOrderItems[index];
                      // Tra cứu tên món
                      String itemName = "Món không rõ";
                      double itemPrice = 0;
                      try {
                        final item = allItems.firstWhere((i) => i.id == orderItem.itemId);
                        itemName = item.name;
                        itemPrice = item.price;
                      } catch (e) {
                        // Bỏ qua nếu không tìm thấy item
                      }
                      return _detailRow("$itemName x${orderItem.quantity}",
                          formatCurrency(itemPrice * orderItem.quantity));
                    },
                  );
                },
              ),

              const SizedBox(height: 15),
              const Text("Tính tiền chi tiết",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              // SỬA: Dùng dữ liệu từ payment
              _detailRow("Tổng sản phẩm", 
                formatCurrency(thisPayment?.totalAmount ?? 0)),
              _detailRow("Giảm giá", 
                formatCurrency(thisPayment?.discountAmount ?? 0)),
              _detailRow("Tổng thanh toán", 
                formatCurrency(thisPayment?.finalAmount ?? 0), 
                isBoldKey: true, isBoldValue: true),

              const SizedBox(height: 15),
              const Text("Thanh toán",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              _detailRow("Phương thức", "Tiền mặt (Giả lập)"),
              _detailRow("Trạng thái thanh toán", "Thành Công", isBoldValue: true),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("In hóa đơn",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // (Hàm _detailRow giữ nguyên)
  Widget _detailRow(String key, String value, {bool isBoldKey = false, bool isBoldValue = false, Color keyColor = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(
            color: isBoldKey ? Colors.black : keyColor, 
            fontWeight: isBoldKey ? FontWeight.bold : FontWeight.normal
          )),
          Text(value, style: TextStyle(
            fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.normal
          )),
        ],
      ),
    );
  }
}