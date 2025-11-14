import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/API/order_API.dart';
import 'package:mart_dine/API/order_item_API.dart';
import 'package:mart_dine/API/payment_API.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/models/item.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/models/payment.dart';
import 'package:mart_dine/providers/menu_item_provider.dart';
import 'package:mart_dine/providers/user_provider.dart';

class ScreenPayment extends ConsumerStatefulWidget {
  final int tableId;
  final String tableName;
  final Order order;
  final List<OrderItem> orderItems;
  final int? companyId;

  const ScreenPayment({
    super.key,
    required this.tableId,
    required this.tableName,
    required this.order,
    required this.orderItems,
    this.companyId,
  });

  @override
  ConsumerState<ScreenPayment> createState() => _ScreenPaymentState();
}

class _ScreenPaymentState extends ConsumerState<ScreenPayment> {
  String _selectedPaymentMethod = 'Phương thức thanh toán';
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'Phương thức thanh toán',
    'Tiền mặt',
    'Chuyển khoản',
    'Thẻ',
  ];

  @override
  void initState() {
    super.initState();
    // Load menu items if companyId is provided
    if (widget.companyId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(menuNotifierProvider.notifier)
            .loadMenusByCompanyId(widget.companyId!);
      });
    }
  }

  // Tính tổng tiền
  double _calculateTotal() {
    // Lấy thông tin món ăn từ itemId
    final menuItems = ref.watch(menuNotifierProvider);
    final menuMap = <int, Item>{};
    for (final menuItem in menuItems) {
      final id = menuItem.id;
      if (id != null) {
        menuMap[id] = menuItem;
      }
    }

    return widget.orderItems.fold(0.0, (sum, item) {
      final menuItem = menuMap[item.itemId];
      if (menuItem != null) {
        return sum + (item.quantity * menuItem.price);
      }
      return sum;
    });
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'Phương thức thanh toán') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phương thức thanh toán')),
      );
      return;
    }

    // Kiểm tra xem tất cả món đã được phục vụ chưa
    final unservedItems =
        widget.orderItems.where((item) => item.statusId != 3).toList();
    if (unservedItems.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể thanh toán! Còn ${unservedItems.length} món chưa được phục vụ.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final total = _calculateTotal();
      final currentUser = ref.read(userNotifierProvider);
      int? cashierId;
      final currentUserId = currentUser?.id;
      if (currentUserId != null && currentUserId > 0) {
        cashierId = currentUserId;
      } else if (widget.order.userId > 0) {
        cashierId = widget.order.userId;
      }

      // Tạo payment
      final payment = Payment(
        orderId: widget.order.id,
        amount: total,
        paymentMethod: _selectedPaymentMethod,
        branchId: widget.order.branchId,
        companyId: widget.order.companyId,
        cashierId: cashierId,
      );

      final paymentApi = ref.read(paymentApiProvider);
      final createdPayment = await paymentApi.createPayment(payment);

      if (createdPayment == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tạo thanh toán')),
          );
        }
        return;
      }

      // Cập nhật trạng thái order thành đã thanh toán (statusId = 3)
      final orderApi = ref.read(orderApiProvider);
      final updatedOrder = await orderApi.updateOrderStatusAlt(
        widget.order.id,
        3,
      );
      print('Updated order status: ${updatedOrder?.statusId}');

      if (mounted) {
        // Hiển thị dialog thành công
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.green.shade700,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Thanh toán thành công',
                      style: Style.fontTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year} - ${widget.order.createdAt.hour}:${widget.order.createdAt.minute.toString().padLeft(2, '0')}',
                      style: Style.fontNormal.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng dialog
                      Navigator.of(context).pop(); // Quay về màn hình chọn bàn
                      Navigator.of(
                        context,
                      ).pop(); // Quay về màn hình chọn bàn (thêm một lần nữa để đảm bảo quay về đúng màn hình)
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi thanh toán: $e')));
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Thu Ngân', style: Style.fontTitle),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              // TODO: In hóa đơn
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Menu khác
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thông tin bàn
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bàn: ${widget.tableName}',
                  style: Style.fontTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thời gian: ${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year} - ${widget.order.createdAt.hour}:${widget.order.createdAt.minute.toString().padLeft(2, '0')}',
                  style: Style.fontNormal.copyWith(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Danh sách món
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Danh sách món ăn',
                  style: Style.fontTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...widget.orderItems.map((item) => _buildOrderItem(item)),
                const Divider(height: 32),

                // Tổng tiền
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng:',
                      style: Style.fontTitle.copyWith(fontSize: 18),
                    ),
                    Text(
                      '${total.toStringAsFixed(0)} VNĐ',
                      style: Style.fontTitle.copyWith(
                        fontSize: 18,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Chọn phương thức thanh toán
                Text(
                  'Chọn phương thức thanh toán:',
                  style: Style.fontTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      isExpanded: true,
                      items:
                          _paymentMethods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nút thanh toán
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Nút Lưu Hóa Đơn
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Lưu hóa đơn
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.orange.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Lưu Hóa Đơn',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nút Thanh toán
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isProcessing
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Thanh toán',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildOrderItem(OrderItem item) {
    // Lấy thông tin món ăn từ itemId
    final menuItems = ref.watch(menuNotifierProvider);
    final menuItem = menuItems.firstWhere(
      (menu) => menu.id == item.itemId,
      orElse:
          () => Item(
            companyId: 0,
            name: 'Món ${item.itemId}',
            price: 0.0,
            statusId: 1,
          ),
    );

    final itemPrice = menuItem.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Số lượng
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'x${item.quantity}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          // Tên món
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuItem.name,
                  style: Style.fontNormal.copyWith(fontSize: 14),
                ),
                if (item.note != null && item.note!.isNotEmpty)
                  Text(
                    item.note!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          // Giá
          Text(
            '${itemPrice.toStringAsFixed(0)}đ',
            style: Style.fontNormal.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
