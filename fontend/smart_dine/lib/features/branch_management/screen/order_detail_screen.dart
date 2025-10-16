import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final String tableName;
  final String date;
  final String amount;
  final String status;
  final Color statusColor;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.tableName,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

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
            // Chi nhánh A card
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
                        'Chi nhánh G6M',
                        style: Style.fontTitleMini.copyWith(color: textColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          status,
                          style: Style.fontCaption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Mã đơn:', orderId, textColor),
                  _buildInfoRow('Tạo ngày:', date, textColor),
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
                  _buildInfoRow('Bàn', tableName, textColor),
                  _buildInfoRow('Nhân viên phục vụ', _getEmployeeName(orderId), textColor),
                  _buildInfoRow('Khách hàng', _getCustomerName(orderId), textColor),
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
                children: _getOrderItems(orderId).asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      if (index > 0) const Divider(height: 24),
                      _buildOrderItem(
                        item['name']!,
                        item['qty']!,
                        item['price']!,
                        item['note']!,
                        textColor,
                      ),
                    ],
                  );
                }).toList(),
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
                  _buildInfoRow('Tạm tính', _getPaymentDetails(orderId)['subtotal']!, textColor),
                  const SizedBox(height: 8),
                  _buildInfoRow('Thuế VAT (10%)', _getPaymentDetails(orderId)['tax']!, textColor),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Tổng thanh toán',
                    _getPaymentDetails(orderId)['total']!,
                    textColor,
                    isTotal: true,
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
                  _buildInfoRow('Tú', 'Tiền mặt', textColor),
                  _buildInfoRow('Trạng thái thanh toán', 'Thành Công', textColor),
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
                  style: Style.fontButton.copyWith(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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

  // Helper functions để lấy dữ liệu dựa trên orderId
  String _getEmployeeName(String orderId) {
    final employees = {
      '#ĐH001': 'Hà Đức Lương',
      '#ĐH002': 'Phúc',
      '#ĐH003': 'Tú Kiệt',
      '#ĐH004': 'Hà Đức Lương',
      '#ĐH005': 'Phúc',
      '#ĐH006': 'Tú Kiệt',
    };
    return employees[orderId] ?? 'Nhân viên';
  }

  String _getCustomerName(String orderId) {
    final customers = {
      '#ĐH001': 'Khách vãng lai',
      '#ĐH002': 'Nguyễn Minh Tuấn',
      '#ĐH003': 'Trần Thu Hà',
      '#ĐH004': 'Lê Hoàng Nam',
      '#ĐH005': 'Phạm Thị Mai',
      '#ĐH006': 'Đỗ Văn Khoa',
    };
    return customers[orderId] ?? 'Khách hàng';
  }

  List<Map<String, String>> _getOrderItems(String orderId) {
    final orderData = {
      '#ĐH001': [
        {'name': 'Phở bò', 'qty': 'x2', 'price': '160,000đ', 'note': ''},
        {'name': 'Cà phê sữa', 'qty': 'x2', 'price': '40,000đ', 'note': ''},
        {'name': 'Trà đá', 'qty': 'x2', 'price': '10,000đ', 'note': 'không đường'},
      ],
      '#ĐH002': [
        {'name': 'Bún chả', 'qty': 'x3', 'price': '210,000đ', 'note': 'thêm chả'},
        {'name': 'Nem rán', 'qty': 'x2', 'price': '60,000đ', 'note': ''},
        {'name': 'Trà sữa', 'qty': 'x2', 'price': '80,000đ', 'note': 'ít đá'},
      ],
      '#ĐH003': [
        {'name': 'Bánh mì thịt', 'qty': 'x2', 'price': '60,000đ', 'note': 'không rau mùi'},
        {'name': 'Cà phê đen', 'qty': 'x2', 'price': '40,000đ', 'note': ''},
      ],
      '#ĐH004': [
        {'name': 'Cơm gà', 'qty': 'x2', 'price': '140,000đ', 'note': ''},
        {'name': 'Gỏi cuốn', 'qty': 'x4', 'price': '80,000đ', 'note': ''},
        {'name': 'Nước chanh', 'qty': 'x2', 'price': '30,000đ', 'note': 'ít đường'},
      ],
      '#ĐH005': [
        {'name': 'Lẩu Thái', 'qty': 'x1', 'price': '350,000đ', 'note': 'cay vừa'},
        {'name': 'Bò cuốn lá lốt', 'qty': 'x1', 'price': '120,000đ', 'note': ''},
        {'name': 'Bia Sài Gòn', 'qty': 'x3', 'price': '50,000đ', 'note': ''},
      ],
      '#ĐH006': [
        {'name': 'Phở gà', 'qty': 'x1', 'price': '70,000đ', 'note': 'không hành'},
        {'name': 'Nước suối', 'qty': 'x2', 'price': '20,000đ', 'note': ''},
      ],
    };
    return orderData[orderId] ?? [
      {'name': 'Món ăn', 'qty': 'x1', 'price': '0đ', 'note': ''},
    ];
  }

  Map<String, String> _getPaymentDetails(String orderId) {
    final payments = {
      '#ĐH001': {'subtotal': '210,000đ', 'tax': '21,000đ', 'total': '231,000đ'},
      '#ĐH002': {'subtotal': '350,000đ', 'tax': '35,000đ', 'total': '385,000đ'},
      '#ĐH003': {'subtotal': '100,000đ', 'tax': '10,000đ', 'total': '110,000đ'},
      '#ĐH004': {'subtotal': '250,000đ', 'tax': '25,000đ', 'total': '275,000đ'},
      '#ĐH005': {'subtotal': '520,000đ', 'tax': '52,000đ', 'total': '572,000đ'},
      '#ĐH006': {'subtotal': '90,000đ', 'tax': '9,000đ', 'total': '99,000đ'},
    };
    return payments[orderId] ?? {'subtotal': '0đ', 'tax': '0đ', 'total': '0đ'};
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
