import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/order_management_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final int orderId;
  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    final orderAsync = ref.watch(orderManagementProvider.notifier).getOrderById(orderId);

    return FutureBuilder(
      future: orderAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Không tìm thấy dữ liệu đơn hàng'));
        }
        final order = snapshot.data!;
        return Scaffold(
          backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
          appBar: AppBarCus(
            title: 'Chi tiết đơn',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chi nhánh card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.branchName ?? 'Chi nhánh',
                            style: Style.fontTitleMini.copyWith(color: textColor),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Text(
                              order.getStatusName(),
                              style: Style.fontCaption.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Mã đơn:', order.id?.toString() ?? '', textColor),
                      _buildInfoRow('Tạo ngày:', order.getFormattedDate(), textColor),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Thông tin bàn
                Text(
                  'Thông tin bàn',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Bàn', order.getTableDisplayName(), textColor),
                      _buildInfoRow('Nhân viên phục vụ', order.userName ?? '', textColor),
                      // Nếu có trường customerName trong order, hãy dùng ở đây. Nếu không, có thể bỏ qua hoặc thay bằng giá trị khác.
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Danh sách món
                Text(
                  'Danh sách món',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: order.items?.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Column(
                        children: [
                          if (index > 0) const Divider(height: 24),
                          _buildOrderItem(
                            item.itemName ?? '',
                            'x${item.quantity}',
                            item.itemPrice != null ? '${item.itemPrice!.toStringAsFixed(0)}đ' : '',
                            item.note ?? '',
                            textColor,
                          ),
                        ],
                      );
                    }).toList() ?? [],
                  ),
                ),
                const SizedBox(height: 20),

                // Tính tiền chi tiết
                Text(
                  'Tính tiền chi tiết',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Tạm tính', '${order.totalAmount ?? 0}đ', textColor),
                      // You can add more payment details if available in the order model
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Tổng thanh toán', '${order.totalAmount ?? 0}đ', textColor, isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Thanh toán
                Text(
                  'Thanh toán',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(order.userName ?? '', 'Tiền mặt', textColor),
                      _buildInfoRow('Trạng thái thanh toán', order.getStatusName(), textColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Button In hóa đơn
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đang in hóa đơn...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'In hóa đơn',
                      style: Style.fontTitleMini.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Style.fontNormal.copyWith(
              color: isTotal ? textColor : Style.textColorGray,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Style.fontNormal.copyWith(
              color: textColor,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    String itemName,
    String quantity,
    String price,
    String note,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              itemName,
              style: Style.fontNormal.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              quantity,
              style: Style.fontNormal.copyWith(color: textColor),
            ),
          ],
        ),
        if (note.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            note,
            style: Style.fontCaption.copyWith(
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            price,
            style: Style.fontNormal.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
