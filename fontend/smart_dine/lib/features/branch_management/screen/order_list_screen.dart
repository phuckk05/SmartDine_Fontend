import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/features/branch_management/screen/order_detail_screen.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    // Dữ liệu mẫu danh sách đơn hàng
    final orders = [
      {
        'id': '#ĐH001',
        'table': 'Bàn 05',
        'date': '16-10-2025 12:30',
        'amount': '285,000 đ',
        'status': 'Đã thanh toán',
        'statusColor': Colors.green,
      },
      {
        'id': '#ĐH002',
        'table': 'Bàn 12',
        'date': '16-10-2025 12:15',
        'amount': '450,000 đ',
        'status': 'Đang phục vụ',
        'statusColor': Colors.blue,
      },
      {
        'id': '#ĐH003',
        'table': 'Bàn 03',
        'date': '16-10-2025 11:45',
        'amount': '180,000 đ',
        'status': 'Đã thanh toán',
        'statusColor': Colors.green,
      },
      {
        'id': '#ĐH004',
        'table': 'Bàn 08',
        'date': '16-10-2025 11:20',
        'amount': '320,000 đ',
        'status': 'Chờ thanh toán',
        'statusColor': Colors.orange,
      },
      {
        'id': '#ĐH005',
        'table': 'Bàn 15',
        'date': '16-10-2025 10:50',
        'amount': '520,000 đ',
        'status': 'Đã thanh toán',
        'statusColor': Colors.green,
      },
      {
        'id': '#ĐH006',
        'table': 'Bàn 07',
        'date': '16-10-2025 10:30',
        'amount': '195,000 đ',
        'status': 'Đã hủy',
        'statusColor': Colors.red,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBarCus(
        title: 'Danh sách đơn hàng',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tất cả thông tin đơn hàng',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(
                    order['id'] as String,
                    order['table'] as String,
                    order['date'] as String,
                    order['amount'] as String,
                    order['status'] as String,
                    order['statusColor'] as Color,
                    cardColor,
                    textColor,
                    context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    String orderId,
    String tableName,
    String date,
    String amount,
    String status,
    Color statusColor,
    Color cardColor,
    Color textColor,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(
              orderId: orderId,
              tableName: tableName,
              date: date,
              amount: amount,
              status: status,
              statusColor: statusColor,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      orderId,
                      style: Style.fontTitleMini.copyWith(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tableName,
                        style: Style.fontCaption.copyWith(
                          color: Colors.blue,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: Style.fontCaption.copyWith(
                    color: Style.textColorGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: Style.fontNormal.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
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
        ],
      ),
    ),
    );
  }
}
