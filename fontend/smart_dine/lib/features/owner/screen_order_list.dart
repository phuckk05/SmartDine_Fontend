// file: screens/screen_order_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/order.dart';
import 'package:mart_dine/models_owner/payment.dart';
import 'package:mart_dine/providers_owner/order_provider.dart';
import 'package:mart_dine/providers_owner/payment_provider.dart';
import 'package:mart_dine/providers_owner/role_provider.dart'; // Lấy formatDate/formatCurrency
import 'screen_order_detail.dart';

class ScreenOrderList extends ConsumerStatefulWidget {
  // <<< THÊM: Nhận branchId >>>
  // Làm nullable (?) để màn hình này vẫn có thể dùng độc lập (hiển thị tất cả)
  final int? branchId;

  const ScreenOrderList({super.key, this.branchId});

  @override
  ConsumerState<ScreenOrderList> createState() => _ScreenOrderListState();
}

class _ScreenOrderListState extends ConsumerState<ScreenOrderList> {
  DateTime? _selectedDate; // State để lưu ngày được chọn

  // Hàm hiển thị date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Hàm xóa bộ lọc ngày
  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
  }
  
  @override
  // SỬA: Xóa 'WidgetRef ref' khỏi chữ ký phương thức. 'ref' có sẵn như một thuộc tính trong ConsumerState.
  Widget build(BuildContext context) {
    // SỬA: Watch provider mới (FutureProvider)
    // SỬA: Chọn provider dựa trên việc widget.branchId có được cung cấp hay không.
    final ordersAsync = widget.branchId == null
        ? ref.watch(allOrdersProvider)
        : ref.watch(ordersByBranchProvider(widget.branchId!));
    final payments = ref.watch(paymentProvider); // SỬA: Dùng watch để UI tự cập nhật khi payment thay đổi

    // Helper để so sánh ngày mà không cần quan tâm đến giờ, phút, giây
    bool isSameDay(DateTime date1, DateTime date2) {
      return date1.year == date2.year &&
             date1.month == date2.month &&
             date1.day == date2.day;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterHeader(), // SỬA: Tách header ra widget riêng
          const SizedBox(height: 12),
          Expanded(
            // SỬA: Dùng .when để xử lý các trạng thái của FutureProvider
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Lỗi tải đơn hàng: $err")),
              data: (orders) {
                var ordersToShow = orders;
                // THÊM: Lọc theo ngày đã chọn
                if (_selectedDate != null) {
                  ordersToShow = ordersToShow.where((order) => isSameDay(order.createdAt, _selectedDate!)).toList();
                }

                if (ordersToShow.isEmpty) {
                  return Center(child: Text(_selectedDate == null ? "Không có đơn hàng nào." : "Không có đơn hàng trong ngày đã chọn."));
                }

                return ListView.builder(
                  itemCount: ordersToShow.length,
                  itemBuilder: (context, index) {
                    final order = ordersToShow[index];
                    
                    Payment? payment;
                    try {
                      payment = payments.firstWhere((p) => p.orderId == order.id);
                    } catch (e) { /*...*/ }
                    
                    final orderName = "Đơn hàng #${order.id}"; 
                    final orderDate = formatDate(order.createdAt);
                    final orderAmount = payment != null 
                                        ? formatCurrency(payment.finalAmount) 
                                        : "0 đ";
                    final orderWeek = "Tuần ${index + 1}"; // Giả lập

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScreenOrderDetail(order: order),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(orderName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(orderDate, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(orderAmount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Text(
                                    orderWeek, 
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho phần tiêu đề và bộ lọc
  Widget _buildFilterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            _selectedDate == null
                ? (widget.branchId == null ? "Tất cả đơn hàng" : "Đơn hàng của chi nhánh")
                : "Đơn hàng ngày: ${formatDate(_selectedDate!)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedDate != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: _clearDateFilter,
                tooltip: 'Xóa bộ lọc ngày',
              ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.blue),
              onPressed: () => _selectDate(context),
              tooltip: 'Lọc theo ngày',
            ),
          ],
        ),
      ],
    );
  }
}