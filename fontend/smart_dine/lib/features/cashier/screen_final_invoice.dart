import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/models/order.dart'; // Import OrderModel
import 'package:mart_dine/providers/order_provider.dart'; // Import order_provider
// import 'package:qr_flutter/qr_flutter.dart'; // Uncomment nếu dùng QR động

class ScreenFinalInvoice extends ConsumerWidget {
  final String orderId;

  const ScreenFinalInvoice({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider.notifier).getOrderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy hóa đơn.')),
      );
    }

    final currencyFormatter = NumberFormat('#,###', 'vi_VN');
    final dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black), // Nút đóng thay vì back
          onPressed: () {
            // Quay về màn hình chính của thu ngân (pop 3 lần: Invoice -> Payment -> DetailView)
            int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 3);
          },
        ),
        title: const Text('Chi tiết hóa đơn', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa nội dung
          children: [
            const Text(
              '*******', // Dấu sao như trong hình
              style: TextStyle(fontSize: 20, letterSpacing: 5),
            ),
            const SizedBox(height: 16),
            Text(
              'Bàn: ${order.tableName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Thời gian: ${dateTimeFormatter.format(order.orderTime)}'),
            Text('Mã đơn: ${order.id.substring(0, 8).toUpperCase()}'), // Mã đơn ngắn gọn
            Text('Số khách: ${order.customerCount}'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Danh sách món ăn
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn trái cho danh sách món
              children: order.items.map((dish) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'x1 ${dish.name}', // Số lượng tạm thời là 1
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Text(
                          '${currencyFormatter.format(dish.price)}đ',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )).toList(),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${currencyFormatter.format(order.totalAmount)} VNĐ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Mã QR Code
            Center( // Căn giữa mã QR
              child: Column(
                children: [
                  const Text(
                    'Quét mã QR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Uncomment và thay thế bằng QR code thực tế nếu dùng qr_flutter
                    // child: QrImageView(
                    //   data: 'MartDineInvoice_${order.id}', // Dữ liệu QR code
                    //   version: QrVersions.auto,
                    //   size: 150.0,
                    // ),
                    // Hiện tại dùng ảnh mẫu từ imgur
                    child: Image.network(
                      'https://i.imgur.com/G4Y4h4y.png', // Ảnh QR code mẫu
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text( // Tên mẫu
                    'Nguyễn Ngọc Đạt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nút Xong
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   // Quay về màn hình chính của thu ngân (pop 3 lần)
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Xong'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}