import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/staff/screen_book_table.dart';
import 'package:mart_dine/features/staff/screen_menu.dart';
import 'package:mart_dine/features/staff/screen_notifications.dart';
import 'package:mart_dine/features/staff/screen_settings.dart';
import 'package:mart_dine/models/table.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/features/staff/table_filter_dialog.dart';

class ScreenChooseTable extends ConsumerWidget {
  const ScreenChooseTable({Key? key}) : super(key: key);

  // 🎨 Màu sắc cho từng trạng thái bàn
  Color _getTableColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return const Color(0xFFE0E0E0); // Xám nhạt cho Trống
      case TableStatus.reserved:
        return const Color(0xFFFFA000); // Cam cho Đã đặt
      case TableStatus.serving:
        return const Color(0xFF3F51B5); // Xanh đậm cho Có khách
    }
  }

  // 🏷️ Văn bản cho từng trạng thái bàn
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

  // 🏷️ Văn bản cho từng khu vực
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

  // 🧩 Dialog nhập số khách khi bàn trống
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
              ref
                  .read(tableProvider.notifier)
                  .setCustomerCount(table.id, guestCount);
              Navigator.pop(context); // Đóng dialog
              // Chuyển sang màn hình chọn món
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

  // 📋 Panel hiển thị thông tin bàn đang phục vụ
  void _showServingPanel(BuildContext context, TableModel table, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final dishes = table.existingItems;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bàn ${table.name}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Số khách: ${table.customerCount ?? 0}'),
              const SizedBox(height: 12),
              const Divider(),
              const Text(
                'Món đang phục vụ:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (dishes.isEmpty)
                const Text('Chưa có món nào.')
              else
                ...dishes.map((e) =>
                    Text('• ${e.name} (${e.price.toStringAsFixed(0)}đ)')),
              const SizedBox(height: 16),
              Text('Tổng tiền: ${table.totalAmount.toStringAsFixed(0)}đ'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm món'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScreenChooseMenu(
                            tableName: table.name,
                            initialGuestCount: table.customerCount ?? 1,
                            existingItems:
                                table.existingItems.map((item) => item.id).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Thanh toán'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700]),
                    onPressed: () {
                      Navigator.pop(context);
                      _showCheckoutDialog(context, table, ref);
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

  // 💰 Dialog xác nhận thanh toán
  // 💰 Dialog xác nhận thanh toán
  void _showCheckoutDialog(
      BuildContext context, TableModel initialTable, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog( // ✅ Sử dụng dialogContext ở đây
        // Lấy lại bàn từ provider để đảm bảo dữ liệu luôn cập nhật
        // (Cách này tốt cho việc hiển thị dữ liệu mới nhất, không phải nguyên nhân lỗi crash)
        title: Text('Thanh toán - ${initialTable.name}'), // Dùng initialTable.name
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Số khách: ${initialTable.customerCount ?? 0}'),
            const SizedBox(height: 6),
            Text('Tổng tiền: ${initialTable.totalAmount.toStringAsFixed(0)}đ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // ✅ Pop dialogContext
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Lấy lại bàn từ provider để đảm bảo dữ liệu luôn cập nhật
              // (Quan trọng hơn ở đây để đảm bảo checkout đúng bàn nếu có thay đổi)
              final table = ref.read(tableProvider).tables.firstWhere(
                (t) => t.id == initialTable.id,
                orElse: () => initialTable, // Fallback an toàn
              );

              ref.read(tableProvider.notifier).checkout(table.id);
              Navigator.pop(dialogContext); // ✅ Pop dialogContext ngay sau khi xử lý
              ScaffoldMessenger.of(dialogContext).showSnackBar( // ✅ Sử dụng dialogContext
                SnackBar(
                  content: Text('Đã thanh toán cho ${table.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tableProvider.notifier);
    final filteredTables = ref.watch(filteredTablesProvider);
    final currentFilterStatus = ref.watch(tableProvider.select((s) => s.filterStatus));
    final currentFilterZone = ref.watch(tableProvider.select((s) => s.filterZone));
    final currentSearchQuery = ref.watch(tableProvider.select((s) => s.searchQuery));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chọn bàn', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenBookTable())); }, icon: const Icon(Icons.table_restaurant), tooltip: 'Đặt bàn'),
          IconButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenNotifications())); }, icon: const Icon(Icons.notifications_none), tooltip: 'Thông báo'),
          IconButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenSettings())); }, icon: const Icon(Icons.settings), tooltip: 'Cài đặt'),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm và nút lọc
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

            // Chú giải màu sắc
            _buildLegend(),
            const SizedBox(height: 16),

            // Danh sách bàn ăn
            Expanded(
              child: filteredTables.isEmpty
                  ? const Center(child: Text('Không tìm thấy bàn nào phù hợp.'))
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: filteredTables.length,
                      itemBuilder: (context, index) {
                        final table = filteredTables[index];
                        final color = _getTableColor(table.status);
                        final zoneText = _getZoneText(table.zone);
                        final isAvailable = table.status == TableStatus.available;
                        return GestureDetector(
                          onTap: () {
                            notifier.selectTable(table);
                            switch (table.status) {
                              case TableStatus.available: _showGuestDialog(context, table, ref); break;
                              case TableStatus.reserved: Navigator.push(context, MaterialPageRoute(builder: (_) => ScreenChooseMenu(tableName: table.name, initialGuestCount: table.customerCount ?? 1, existingItems: table.existingItems.map((item) => item.id).toList()))); break;
                              case TableStatus.serving: _showServingPanel(context, table, ref); break;
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(alignment: Alignment.center, child: Text(table.name, style: TextStyle(color: isAvailable ? Colors.black : Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.person, size: 14, color: isAvailable ? Colors.black54 : Colors.white),
                                        const SizedBox(width: 4),
                                        Text('${table.seats} chỗ', style: TextStyle(color: isAvailable ? Colors.black54 : Colors.white, fontSize: 12)),
                                      ]),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: isAvailable ? Colors.grey[300] : Colors.white24, borderRadius: BorderRadius.circular(10)),
                                        child: Text(zoneText, style: TextStyle(color: isAvailable ? Colors.black87 : Colors.white, fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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

  // Widget xây dựng phần chú giải màu sắc
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

  // Widget cho một mục trong chú giải
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}