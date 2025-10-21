import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/providers/order_provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';

class ScreenCashierPayment extends ConsumerStatefulWidget {
  final String orderId;

  const ScreenCashierPayment({Key? key, required this.orderId}) : super(key: key);

  @override
  ConsumerState<ScreenCashierPayment> createState() => _ScreenCashierPaymentState();
}

class _ScreenCashierPaymentState extends ConsumerState<ScreenCashierPayment> {
  OrderPaymentMethod? _selectedPaymentMethod;
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider.notifier).getOrderById(widget.orderId);

    if (order == null) {
      // Xử lý trường hợp không tìm thấy đơn hàng (có thể quay lại hoặc hiển thị lỗi)
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Đơn hàng không tồn tại.')),
      );
    }

    final currencyFormatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Thu Ngân', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history, color: Colors.black), tooltip: 'Lịch sử giao dịch'),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black), tooltip: 'Thông báo'),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Bàn: ${order.tableName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Center( // Hiển thị Order ID nếu cần
               child: Text(
                 'Order No.${order.id.substring(0, 6).toUpperCase()}',
                 style: const TextStyle(fontSize: 14, color: Colors.grey),
               ),
             ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final dish = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(child: Text('x1 ${dish.name}', style: const TextStyle(fontSize: 16))),
                        Text('${currencyFormatter.format(dish.price)}đ', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng cộng :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${currencyFormatter.format(order.totalAmount)} VNĐ',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            const Text(
              'Chọn phương thức thanh toán:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<OrderPaymentMethod>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text('Phương thức thanh toán'),
              items: OrderPaymentMethod.values.map((method) {
                String methodName = '';
                switch (method) {
                  case OrderPaymentMethod.cash: methodName = 'Tiền mặt'; break;
                  case OrderPaymentMethod.qrCode: methodName = 'Quét mã QR'; break;
                  case OrderPaymentMethod.creditCard: methodName = 'Thẻ tín dụng'; break;
                }
                return DropdownMenuItem(value: method, child: Text(methodName));
              }).toList(),
              onChanged: (method) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
            ),
            const Spacer(), // Đẩy nút xuống dưới
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessingPayment ? null : () async {
                  if (_selectedPaymentMethod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn phương thức thanh toán.'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  setState(() => _isProcessingPayment = true);
                  await Future.delayed(const Duration(seconds: 2)); // Simulate processing
                  ref.read(orderProvider.notifier).markOrderAsPaid(widget.orderId, _selectedPaymentMethod!);
                  setState(() => _isProcessingPayment = false);
                  _showPaymentSuccessDialog(context, order.tableName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isProcessingPayment
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('Thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog thông báo thanh toán thành công
  void _showPaymentSuccessDialog(BuildContext context, String tableName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Thanh toán thành công!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Hóa đơn bàn $tableName đã được thanh toán.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Đóng dialog thành công
                // Quay lại màn hình danh sách hóa đơn (pop 2 lần)
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Xong'),
            ),
          ],
        ),
      ),
    );
  }
}