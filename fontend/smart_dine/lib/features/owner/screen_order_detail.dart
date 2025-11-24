// file: screens/screen_order_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/order.dart';
import 'package:mart_dine/models_owner/order_items.dart';
import 'package:mart_dine/models_owner/item.dart';
import 'package:mart_dine/models_owner/payment.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/providers_owner/item_provider.dart';
import 'package:mart_dine/providers_owner/order_item_provider.dart';
import 'package:mart_dine/providers_owner/menu_item_relation_provider.dart';
import 'package:mart_dine/providers_owner/payment_provider.dart';
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';
import 'package:mart_dine/providers_owner/role_provider.dart'; // Import helper
import 'package:mart_dine/providers_owner/table_provider.dart';
import 'package:mart_dine/providers_owner/target_provider.dart';

// SỬA: Chuyển thành ConsumerWidget
class ScreenOrderDetail extends ConsumerWidget {
  // SỬA: Yêu cầu Order object
  final Order order;

  const ScreenOrderDetail({super.key, required this.order});

  // SỬA: Cập nhật hàm lấy màu và tên trạng thái từ Payment
  Color _getStatusColor(Payment? payment) {
    // Giả định: statusId = 1 là "Đã thanh toán"
    return payment?.statusId == 1 ? Colors.green : Colors.orange;
  }

  String _getStatusName(Payment? payment) {
    if (payment == null) return "Chưa có";
    // Giả định: statusId = 1 là "Đã thanh toán"
    return payment.statusId == 1 ? "Đã trả" : "Chưa trả";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SỬA: Lấy dữ liệu từ các provider
    final allOrderItems = ref.watch(orderItemProvider);
    final allItemsAsync = ref.watch(allItemsProvider(order.companyId));
    final allStaffAsync = ref.watch(staffProfileProvider);
    final allPayments = ref.watch(paymentProvider);
    final allBranchesAsync = ref.watch(branchListProvider);
    final allTablesAsync = ref.watch(tableNotifierProvider);

    // SỬA: Lọc dữ liệu cho đơn hàng này
    final thisOrderItems =
        allOrderItems.where((oi) => oi.orderId == order.id).toList();

    // Tìm Payment
    Payment? thisPayment;
    try {
      thisPayment = allPayments.firstWhere((p) => p.orderId == order.id);
    } catch (e) {}

    // Helper để lấy dữ liệu từ các provider Async
    final staffName = allStaffAsync.when(
      data: (staffList) {
        try {
          return staffList
              .firstWhere((s) => s.user.id == order.userId)
              .user
              .fullName;
        } catch (e) {
          return "Không rõ";
        }
      },
      loading: () => "Đang tải...",
      error: (_, __) => "Lỗi",
    );

    final branchName = allBranchesAsync.when(
        data: (branches) {
          try {
            return branches.firstWhere((b) => b.id == order.branchId).name;
          } catch (e) {
            return "Chi nhánh không rõ";
          }
        },
        loading: () => "Đang tải...",
        error: (_, __) => "Lỗi");
    // SỬA: Sửa lỗi "whenData isn't defined for the type 'List'".
    // tableNotifierProvider trả về List<TableDining> trực tiếp, không phải AsyncValue.
    String tableName;
    try {
      // Tìm tên bàn từ danh sách đã có.
      tableName = allTablesAsync.firstWhere((t) => t.id == order.tableId).name;
    } catch (e) {
      tableName = "Bàn không rõ"; // Fallback nếu không tìm thấy.
    }

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
                      Text(branchName,
                          style: const TextStyle( // SỬA: Dùng tên chi nhánh thật
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
                      color: _getStatusColor(thisPayment),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      _getStatusName(thisPayment),
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
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
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
                        final item =
                            allItems.firstWhere((i) => i.id == orderItem.itemId);
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
              _detailRow(
                  "Tổng sản phẩm", formatCurrency(thisPayment?.totalAmount ?? 0)),
              _detailRow(
                  "Giảm giá", formatCurrency(thisPayment?.discountAmount ?? 0)),
              _detailRow("Tổng thanh toán",
                  formatCurrency(thisPayment?.finalAmount ?? 0),
                  isBoldKey: true,
                  isBoldValue: true),

              const SizedBox(height: 15),
              const Text("Thanh toán",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              _detailRow("Phương thức", "Tiền mặt"),
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
  Widget _detailRow(String key, String value,
      {bool isBoldKey = false,
      bool isBoldValue = false,
      Color keyColor = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: TextStyle(
                  color: isBoldKey ? Colors.black : keyColor,
                  fontWeight: isBoldKey ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(
            fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.normal
          )),
        ],
      ),
    );
  }
}