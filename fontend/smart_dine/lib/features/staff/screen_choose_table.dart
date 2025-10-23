import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/cashier/screen_cashier_payment.dart';
import 'package:mart_dine/features/cashier/screen_cashier_pending_payments.dart';
import 'package:mart_dine/features/staff/screen_book_table.dart';
import 'package:mart_dine/features/staff/screen_menu.dart';
import 'package:mart_dine/features/staff/screen_notifications.dart';
import 'package:mart_dine/features/staff/screen_settings.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/models/table.dart';
import 'package:mart_dine/providers/order_provider.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/features/staff/table_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Import để format tiền tệ trong dialog




class ScreenChooseTable extends ConsumerWidget {
  const ScreenChooseTable({Key? key}) : super(key: key);

  // Get color based on table status
  Color _getTableColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return const Color(0xFFE0E0E0); // Light gray for Available
      case TableStatus.reserved:
        return const Color(0xFFFFA000); // Orange for Reserved
      case TableStatus.serving:
        return const Color(0xFF3F51B5); // Dark blue for Serving
    }
  }

  // Get text for table status
  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Trống';
      case TableStatus.reserved:
        return 'Đã đặt';
      case TableStatus.serving:
        return 'Có khách';
    }
  }

  // Get text for table zone
  String _getZoneText(TableZone zone) {
    switch (zone) {
      case TableZone.all:
        return 'Tất cả';
      case TableZone.vip:
        return 'Vip';
      case TableZone.quiet:
        return 'Yên tĩnh';
      case TableZone.indoor:
        return 'Trong nhà';
      case TableZone.outdoor:
        return 'Ngoài trời';
    }
  }

  // Dialog to input guest count for an available table
  void _showGuestDialog(BuildContext context, TableModel table, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bàn ${table.name} - Nhập số khách'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Số khách hàng...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final guestCount = int.tryParse(controller.text.trim()) ?? 0;
              if (guestCount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Số khách phải lớn hơn 0!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              // Set customer count and reserve the table
              ref
                  .read(tableProvider.notifier)
                  .setCustomerCount(table.id, guestCount);
              Navigator.pop(context); // Close dialog
              // Navigate to menu screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScreenChooseMenu(
                    tableName: table.name,
                    initialGuestCount: guestCount,
                    existingItems: const [],
                  ),
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  // Panel showing details for a serving table (for Cashier)
  void _showServingPanel(BuildContext context, TableModel table, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) { // Use a different context name
        final dishes = table.existingItems;
        final isPending = table.isPendingPayment; // Check if staff requested payment

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Name and Guest Count
              Text(
                'Bàn ${table.name}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Số khách: ${table.customerCount ?? 0}'),
              const SizedBox(height: 12),
              const Divider(),
              // List of Served Dishes
              const Text(
                'Món đang phục vụ:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (dishes.isEmpty)
                const Text('Chưa có món nào.')
              else
                ...dishes.map((e) => Text(
                      '• ${e.name} (${e.price.toStringAsFixed(0)}đ)',
                      style: TextStyle(
                          color: isPending ? Colors.grey : Colors.black),
                    )),
              const SizedBox(height: 16),
              // Total Amount
              Text('Tổng tiền: ${table.totalAmount.toStringAsFixed(0)}đ'),
              const SizedBox(height: 16),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Add Dish Button (Cashier can always add)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm món'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                    onPressed: () {
                      Navigator.pop(bottomSheetContext); // Close panel
                      Navigator.push(
                        context, // Use main context for navigation
                        MaterialPageRoute(
                          builder: (_) => ScreenChooseMenu(
                            tableName: table.name,
                            initialGuestCount: table.customerCount ?? 1,
                            existingItems: table.existingItems
                                .map((item) => item.id)
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),

                  // Checkout Button (Cashier) - Navigates directly to Payment
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Thanh toán'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700]),
                    onPressed: () {
                      // 1. Close the bottom sheet
                      Navigator.pop(bottomSheetContext);

                      // 2. Call checkout, create OrderModel, reset table, AND GET ID
                      final String? newOrderId =
                          ref.read(tableProvider.notifier).checkout(table.id);

                      // 3. Navigate directly to the payment screen
                      if (newOrderId != null) {
                        Navigator.push(
                          context, // Use main context for navigation
                          MaterialPageRoute(
                            builder: (ctx) =>
                                ScreenCashierPayment(orderId: newOrderId),
                          ),
                        );
                      } else {
                        // Handle error if order creation failed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Lỗi: Không thể tạo hóa đơn'),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Dialog to show pending payment requests (called from AppBar icon)
  void _showPendingOrdersDialog(BuildContext context, WidgetRef ref, List<OrderModel> pendingOrders) {
     final currencyFormatter = NumberFormat('#,###', 'vi_VN');
     showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yêu cầu thanh toán'),
        content: SizedBox( // Limit dialog height
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.5, // Max 50% screen height
          child: pendingOrders.isEmpty
              ? const Center(child: Text('Không có yêu cầu nào.'))
              : ListView.builder(
                  shrinkWrap: true, // Important for ListView in Dialog
                  itemCount: pendingOrders.length,
                  itemBuilder: (ctx, index) {
                    final order = pendingOrders[index];
                    return ListTile(
                      title: Text('Bàn ${order.tableName}'),
                      subtitle: Text('${order.customerCount} khách - ${DateFormat('HH:mm').format(order.orderTime)}'),
                      trailing: Text('${currencyFormatter.format(order.totalAmount)}đ', style: TextStyle(color: Colors.redAccent)),
                      onTap: () {
                        Navigator.pop(dialogContext); // Close the dialog
                        // Navigate directly to the payment screen for this order
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ScreenCashierPayment(orderId: order.id),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tableProvider.notifier);
    final filteredTables = ref.watch(filteredTablesProvider);
    final currentFilterStatus =
        ref.watch(tableProvider.select((s) => s.filterStatus));
    final currentFilterZone =
        ref.watch(tableProvider.select((s) => s.filterZone));
    final currentSearchQuery =
        ref.watch(tableProvider.select((s) => s.searchQuery));

    // Watch order provider to get pending orders for the badge
    final allOrders = ref.watch(orderProvider);
    final pendingOrders = allOrders.where((order) {
      // Filter logic: Adjust based on the status set in createOrderFromTable
      return order.status == OrderStatus.confirmed; // Assuming 'confirmed' means pending payment
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chọn bàn (Thu Ngân)', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          // Payment Request Notification Icon/Badge
          IconButton(
            tooltip: 'Yêu cầu thanh toán (${pendingOrders.length})',
            onPressed: () {
               // Open the dedicated screen for pending payments
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const ScreenCashierPendingPayments()),
               );
               // OR: Use the dialog if you prefer
               // _showPendingOrdersDialog(context, ref, pendingOrders);
            },
            icon: Badge( // Flutter's built-in Badge widget
              label: Text(pendingOrders.length.toString()),
              isLabelVisible: pendingOrders.isNotEmpty, // Show only if > 0
              child: const Icon(Icons.receipt_long_outlined), // Receipt icon
            ),
          ),
          // Other existing action buttons
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ScreenBookTable()));
              },
              icon: const Icon(Icons.table_restaurant),
              tooltip: 'Đặt bàn'),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ScreenNotifications()));
              },
              icon: const Icon(Icons.notifications_none),
              tooltip: 'Thông báo'),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ScreenSettings()));
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Cài đặt'),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar and Filter Button (No changes needed)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController()..text = currentSearchQuery,
                    onChanged: notifier.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list, size: 30),
                  onPressed: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (BuildContext context) {
                        return TableFilterDialog(
                          currentZone: currentFilterZone,
                          currentStatus: currentFilterStatus,
                        );
                      },
                    );
                    if (result != null) {
                      notifier.setFilterZone(result['zone']);
                      notifier.setFilterStatus(result['status']);
                    }
                  },
                  tooltip: 'Lọc',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color Legend (No changes needed)
            _buildLegend(),
            const SizedBox(height: 16),

            // Table Grid (No changes needed in logic, only presentation)
            Expanded(
              child: filteredTables.isEmpty
                  ? const Center(child: Text('Không tìm thấy bàn nào phù hợp.'))
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12),
                      itemCount: filteredTables.length,
                      itemBuilder: (context, index) {
                        final table = filteredTables[index];
                        final color = _getTableColor(table.status);
                        final zoneText = _getZoneText(table.zone);
                        final isAvailable =
                            table.status == TableStatus.available;
                        return GestureDetector(
                          onTap: () {
                            notifier.selectTable(table);
                            switch (table.status) {
                              case TableStatus.available:
                                _showGuestDialog(context, table, ref);
                                break;
                              case TableStatus.reserved:
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ScreenChooseMenu(
                                            tableName: table.name,
                                            initialGuestCount:
                                                table.customerCount ?? 1,
                                            existingItems: table.existingItems
                                                .map((item) => item.id)
                                                .toList(),
                                            )));
                                break;
                              case TableStatus.serving:
                                _showServingPanel(context, table, ref);
                                break;
                            }
                          },
                          child: Stack(
                            children: [
                              // Table Card content
                              Container(
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                          alignment: Alignment.center,
                                          child: Text(table.name,
                                              style: TextStyle(
                                                  color: isAvailable
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Icon(Icons.person,
                                                size: 14,
                                                color: isAvailable
                                                    ? Colors.black54
                                                    : Colors.white),
                                            const SizedBox(width: 4),
                                            Text('${table.seats} chỗ',
                                                style: TextStyle(
                                                    color: isAvailable
                                                        ? Colors.black54
                                                        : Colors.white,
                                                    fontSize: 12)),
                                          ]),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: isAvailable
                                                    ? Colors.grey[300]
                                                    : Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(zoneText,
                                                style: TextStyle(
                                                    color: isAvailable
                                                        ? Colors.black87
                                                        : Colors.white,
                                                    fontSize: 10)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Payment Pending Icon
                              if (table.isPendingPayment)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.monetization_on,
                                      color: Colors.yellowAccent,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the color legend row (No changes)
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLegendItem(const Color(0xFFE0E0E0), 'Trống'),
        const SizedBox(width: 16),
        _buildLegendItem(const Color(0xFF3F51B5), 'Có khách'),
        const SizedBox(width: 16),
        _buildLegendItem(const Color(0xFFFFA000), 'Đã đặt'),
      ],
    );
  }

  // Helper widget for a single legend item (No changes)
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}