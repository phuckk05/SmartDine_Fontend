import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/staff/screen_menu.dart';
import 'package:mart_dine/features/staff/screen_settings.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/routes.dart';

// THÊM 2 IMPORTS NÀY:
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/API/order_API.dart'; // Để dùng orderApiProvider

class ScreenChooseTable extends ConsumerStatefulWidget {
  const ScreenChooseTable({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenChooseTable> createState() => _ScreenChooseTableState();
}

class _ScreenChooseTableState extends ConsumerState<ScreenChooseTable> {
  //Table provider

  @override
  void initState() {
    super.initState();
    // Bạn không cần hàm loadTableData() ở đây
    // vì TableProvider đã tự gọi getAll() khi khởi tạo.
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
    // TỐI ƯU: watch provider 1 lần ở đây
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
      itemCount: tables.length, // Dùng tables.length
      itemBuilder: (context, index) {
        final table = tables[index]; // Lấy table từ danh sách đã watch

        // Check if table has unpaid orders
        final bool hasUnpaidOrders = unpaidTableIds.when(
          data: (ids) => ids.contains(table.id),
          loading: () => false,
          error: (_, __) => false,
        );

        return InkWell(
          // *** CẬP NHẬT LOGIC ONTAD DƯỚI ĐÂY ***
          onTap: () {
            if (table.id == null) return; // Kiểm tra an toàn
            final tableId = table.id!;
            final tableName = table.name ?? 'Bàn - ${table.id}';

            if (hasUnpaidOrders) {
              // 1. BÀN CÓ NGƯỜI: Hiển thị Dialog
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return _ExistingOrderDialog(
                    tableId: tableId,
                    tableName: tableName,
                  );
                },
              );
            } else {
              // 2. BÀN TRỐNG: Đi tới màn hình Menu
              Routes.pushRightLeftConsumerFul(
                context,
                ScreenMenu(
                  tableId: tableId,
                  tableName: tableName,
                ),
              );
            }
          },
          // *** KẾT THÚC CẬP NHẬT ONTAP ***
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      hasUnpaidOrders
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
                          'Bàn - ${table.id}',
                          style: TextStyle(
                            color:
                                hasUnpaidOrders
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
                                color:
                                    hasUnpaidOrders
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
                                    color:
                                        Theme.of(context).brightness ==
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
                            color:
                                hasUnpaidOrders
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
                              color:
                                  hasUnpaidOrders
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

// *** WIDGET DIALOG MỚI ***

// 1. Provider mới để tải tóm tắt order cho Dialog
final _dialogOrderSummaryProvider =
    FutureProvider.family<List<OrderItem>, int>((ref, tableId) async {
  final orderApi = ref.watch(orderApiProvider);

  // Lấy order (chỉ lấy order đầu tiên của bàn trong ngày)
  final orders = await orderApi.fetchOrdersByTableIdToday(tableId);
  if (orders.isEmpty) {
    return []; // Không có order, trả về list rỗng
  }
  final order = orders.first;

  // Lấy danh sách items của order đó
  final items = await orderApi.fetchOrderItems(order.id.toString());
  return items;
});

// 2. Widget AlertDialog
class _ExistingOrderDialog extends ConsumerWidget {
  final int tableId;
  final String tableName;

  const _ExistingOrderDialog({
    required this.tableId,
    required this.tableName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider mới
    final orderItemsAsync = ref.watch(_dialogOrderSummaryProvider(tableId));

    return AlertDialog(
      title: Text('Order của $tableName'),
      content: Container(
        // Đặt chiều cao cố định để dialog không bị nhảy size khi loading
        height: 70,
        child: orderItemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('Bàn này chưa chọn món.'));
            }
            // Đếm tổng số lượng món
            final totalQuantity =
                items.fold(0, (sum, item) => sum + item.quantity);
            // Đếm số loại món
            final totalItemTypes = items.length;

            return Center(
              child: Text(
                'Đã order $totalItemTypes loại món.\n(Tổng số lượng: $totalQuantity)',
                textAlign: TextAlign.center,
                style: Style.fontNormal,
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(
            child: Text('Lỗi tải chi tiết order.'),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        // Nút Thanh Toán
        TextButton(
          onPressed: () {
            // TODO: Thêm logic gọi API thanh toán ở đây
            Navigator.of(context).pop(); // Đóng dialog
            print('Yêu cầu thanh toán cho bàn $tableId');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã gửi yêu cầu thanh toán cho $tableName')),
            );
          },
          child: Text(
            'Thanh Toán',
            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
          ),
        ),
        // Nút Thêm Món
        ElevatedButton(
          onPressed: () {
            // Đóng dialog VÀ chuyển sang màn hình Menu
            Navigator.of(context).pop();
            Routes.pushRightLeftConsumerFul(
              context,
              ScreenMenu(
                tableId: tableId,
                tableName: tableName,
              ),
            );
          },
          child: const Text('Thêm Món'),
        ),
      ],
    );
  }
}