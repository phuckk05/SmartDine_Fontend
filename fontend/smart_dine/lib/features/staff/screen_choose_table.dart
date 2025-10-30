import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/staff/screen_menu.dart';
import 'package:mart_dine/features/staff/screen_settings.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/API/order_API.dart';

class ScreenChooseTable extends ConsumerStatefulWidget {
  final int? branchId;
  final int? userId; // ✅ THÊM
  final int? companyId; // ✅ THÊM

  const ScreenChooseTable({
    super.key,
    this.branchId,
    this.userId,
    this.companyId,
  });

  @override
  ConsumerState<ScreenChooseTable> createState() => _ScreenChooseTableState();
}

class _ScreenChooseTableState extends ConsumerState<ScreenChooseTable> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTables);
  }

  // Load tables
  Future<void> _loadTables() async {
    final branchId = widget.branchId ?? 1;
    ref.read(tableNotifierProvider.notifier).getAll(branchId);
  }

  // ✅ HÀM HELPER ĐỂ NAVIGATE ĐẾN SCREEN MENU
  void _navigateToMenu(int tableId, String tableName) {
    Routes.pushRightLeftConsumerFul(
      context,
      ScreenMenu(
        tableId: tableId,
        tableName: tableName,
        companyId: widget.companyId ?? 1, // ✅ Truyền companyId
        branchId: widget.branchId ?? 1, // ✅ Truyền branchId
        userId: widget.userId ?? 1, // ✅ Truyền userId
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn bàn', style: Style.fontTitle),
        centerTitle: false,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.table_restaurant),
            tooltip: 'Đặt bàn',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Thông báo',
          ),
          IconButton(
            onPressed: () {
              Routes.pushRightLeftConsumerFul(context, ScreenSettings());
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Cài đặt',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _search(context),
              const SizedBox(height: 16),
              _listTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _search(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            width: double.infinity,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 24,
                  color: Theme.of(context).iconTheme.color,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(LucideIcons.filter, size: 28),
          onPressed: () async {},
          tooltip: 'Lọc',
        ),
      ],
    );
  }

  Widget _listTable() {
    final unpaidTableIds = ref.watch(getUnpaidTableIdsToday);
    final tables = ref.watch(tableNotifierProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];

        // Check if table has unpaid orders
        final bool hasUnpaidOrders = unpaidTableIds.when(
          data: (ids) => ids.contains(table.id),
          loading: () => false,
          error: (_, __) => false,
        );

        return InkWell(
          // ✅ SỬA LOGIC ONTAP
          onTap: () {
            if (table.id == null) return; // Kiểm tra an toàn
            final tableId = table.id!;
            final tableName = table.name ?? 'Bàn ${table.id}';

            if (hasUnpaidOrders) {
              // ✅ BÀN CÓ KHÁCH: Hiện dialog hoặc đi thẳng vào menu
              // Có thể uncomment dialog bên dưới nếu cần
              showDialog(
                context: context,
                builder: (context) => _ExistingOrderDialog(
                  tableId: tableId,
                  tableName: tableName,
                  onAddMore: () {
                    Navigator.of(context).pop();
                    _navigateToMenu(tableId, tableName);
                  },
                  onPayment: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã gửi yêu cầu thanh toán cho $tableName'),
                      ),
                    );
                  },
                ),
              );
            } else {
              // ✅ BÀN TRỐNG: Đi tới màn hình Menu
              _navigateToMenu(tableId, tableName);
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: hasUnpaidOrders
                      ? (Theme.of(context).brightness == Brightness.light
                          ? Colors.blue.shade500
                          : Colors.blue.shade500)
                      : (Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade300
                          : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Bàn ${table.id}',
                          style: TextStyle(
                            color: hasUnpaidOrders
                                ? (Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.white)
                                : (Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.black),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: hasUnpaidOrders
                                    ? (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.red.shade100
                                        : Colors.red.shade300)
                                    : (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.green.shade100
                                        : Colors.green.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  hasUnpaidOrders ? 'Có Khách' : 'Trống',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black87
                                        : Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.person,
                            size: 14,
                            color: hasUnpaidOrders
                                ? (Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.white)
                                : (Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.black),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            table.typeId.toString(),
                            style: TextStyle(
                              color: hasUnpaidOrders
                                  ? (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.white)
                                  : (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.black),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ✅ WIDGET DIALOG ĐƠN GIẢN (Không cần FutureProvider phức tạp)
class _ExistingOrderDialog extends StatelessWidget {
  final int tableId;
  final String tableName;
  final VoidCallback onAddMore;
  final VoidCallback onPayment;

  const _ExistingOrderDialog({
    required this.tableId,
    required this.tableName,
    required this.onAddMore,
    required this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bàn $tableName'),
      content: Text(
        'Bàn này đã có order.\nBạn muốn làm gì?',
        style: Style.fontNormal,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        // Nút Thanh Toán
        TextButton(
          onPressed: onPayment,
          child: Text(
            'Thanh Toán',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Nút Thêm Món
        ElevatedButton(
          onPressed: onAddMore,
          child: const Text('Thêm Món'),
        ),
      ],
    );
  }
}