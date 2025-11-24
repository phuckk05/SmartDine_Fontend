// file: widgets/_staff_detail_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // THÊM
import 'package:mart_dine/models_owner/user.dart';
// SỬA: Import role_provider (đã chứa formatDate và getStatusName)
import 'package:mart_dine/providers_owner/role_provider.dart'; 
import 'package:mart_dine/providers_owner/order_provider.dart'; // THÊM
import 'package:mart_dine/models_owner/order.dart'; // THÊM
import 'package:mart_dine/API_owner/payment_API.dart' show formatCurrency; // THÊM

// --- Widget 1: Card chứa thông tin cơ bản của Nhân viên ---
class StaffInfoCard extends StatelessWidget {
  final User user;
  final String roleName;

  const StaffInfoCard({super.key, required this.user, required this.roleName});

  @override
  Widget build(BuildContext context) {
    String statusName = getStatusName(user.statusId);
    Color statusColor = user.statusId == 1 ? Colors.green : Colors.grey.shade600;
    Color statusBgColor = user.statusId == 1 ? Colors.green.shade100 : Colors.grey.shade300;
    
    // SỬA: Dùng hàm formatDate mới
    final joinDate = formatDate(user.createdAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildInfoRow("Tên nhân viên", user.fullName),
          _buildInfoRow("Ngày tạo tk", joinDate), // Đã format
          _buildInfoRow("Chức vụ", roleName),
          _buildInfoRow("Số điện thoại", user.phone),
          _buildInfoRow("Mail", user.email),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trạng thái", style: TextStyle(fontSize: 14, color: Colors.black54)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(width: 10), // Thêm khoảng cách giữa label và value
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right, // Căn phải cho đẹp hơn
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget 2: Danh sách các đơn hàng đã tạo ---
class StaffOrderList extends ConsumerWidget {
  final int staffId;
  const StaffOrderList({super.key, required this.staffId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SỬA: Watch provider mới để lấy dữ liệu thật
    final allOrdersAsync = ref.watch(allOrdersProvider);

    return allOrdersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text("Lỗi tải đơn hàng: $err"),
      data: (allOrders) {
        // Lọc các đơn hàng của nhân viên này
        final staffOrders = allOrders.where((order) => order.userId == staffId).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Số đơn đã tạo (${staffOrders.length})", // Hiển thị tổng số đơn
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (staffOrders.isEmpty)
              const Text("Nhân viên này chưa tạo đơn hàng nào.")
            else
              // Giới hạn hiển thị 5 đơn hàng gần nhất
              ...staffOrders.take(5).map((order) => _buildOrderItem(order)).toList(),
          ],
        );
      },
    );
  }

  // Widget con để hiển thị một item đơn hàng
  Widget _buildOrderItem(Order order) {
    // TODO: Cần có API để lấy tổng tiền của đơn hàng dựa trên order.id
    // Hiện tại sẽ hiển thị giá trị giả định
    final double totalAmount = 0.0; // Thay thế bằng giá trị thật

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(formatCurrency(totalAmount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(formatDate(order.createdAt), style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}