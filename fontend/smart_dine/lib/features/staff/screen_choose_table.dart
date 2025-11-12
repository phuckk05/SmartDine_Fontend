import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/API/order_API.dart';
import 'package:mart_dine/API/order_item_API.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/cashier/screen_payment.dart';
import 'package:mart_dine/features/revervation/screen_reservation.dart';
import 'package:mart_dine/features/staff/screen_menu.dart';
import 'package:mart_dine/features/staff/screen_settings.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/models/table.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/routes.dart';

class ScreenChooseTable extends ConsumerStatefulWidget {
  final int? branchId;
  final int role; // 1: Nhân viên, 2: Thu ngân
  const ScreenChooseTable({super.key, this.branchId, required this.role});

  @override
  ConsumerState<ScreenChooseTable> createState() => _ScreenChooseTableState();
}

class _ScreenChooseTableState extends ConsumerState<ScreenChooseTable> {
  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  // Loại bỏ dấu tiếng Việt cho tìm kiếm
  String _removeVietnameseDiacritics(String str) {
    const vietnamese =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const english =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    String result = str.toLowerCase();
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], english[i]);
    }
    return result;
  }
  //Table provider

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTables);
  }

  //Load tables
  Future<void> _loadTables() async {
    final branchId = widget.branchId ?? 1;
    await ref.read(tableNotifierProvider.notifier).loadTables(branchId);
    ref.invalidate(unpaidTablesByBranchProvider(branchId));
  }

  // Thay thế phần _openTable trong screen_choose_table.dart

  Future<void> _openTable(DiningTable table, bool hasUnpaidOrders) async {
    Order? initialOrder;
    List<OrderItem> initialItems = const <OrderItem>[];

    if (hasUnpaidOrders) {
      bool dialogOpened = false;
      if (mounted) {
        dialogOpened = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        final orderApi = ref.read(orderApiProvider);
        final orders = await orderApi.fetchOrdersByTableIdToday(table.id);

        if (orders.isNotEmpty) {
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Find the most recent active order for this table.
          // Active means statusId == 2 (being served) or statusId == 4 (requested payment).
          Order? current;
          for (final order in orders) {
            if (order.statusId == 2 || order.statusId == 4) {
              current = order;
              break;
            }
          }

          if (current != null) {
            final orderItemApi = ref.read(orderItemApiProvider);
            final items = await orderItemApi.getOrderItemsByOrderId(current.id);
            initialOrder = current;
            initialItems = List<OrderItem>.from(items);

            // Nếu order có yêu cầu thanh toán (statusId == 4) và là thu ngân, chuyển đến màn hình thanh toán
            if (current.statusId == 4 && widget.role == 2) {
              if (mounted && dialogOpened) {
                Navigator.of(context, rootNavigator: true).pop();
              }

              if (!mounted) return;

              Routes.pushRightLeftConsumerFul(
                context,
                ScreenPayment(
                  tableId: table.id,
                  tableName: table.name,
                  order: current,
                  orderItems: initialItems,
                  companyId: current.companyId,
                ),
              );
              return;
            }
          } else {
            // No active orders (e.g., all orders are paid - statusId == 3).
            initialOrder = null;
            initialItems = const <OrderItem>[];
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tải được order hiện tại: $e')),
          );
        }
      } finally {
        if (mounted && dialogOpened) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    }

    if (!mounted) return;

    Routes.pushRightLeftConsumerFul(
      context,
      ScreenMenu(
        tableId: table.id,
        tableName: table.name,
        branchId: widget.branchId ?? 1,
        companyId: 1,
        userId: 1,
        initialOrder: initialOrder,
        initialOrderItems: initialItems,
        role: widget.role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branchId = widget.branchId ?? 1;
    final unpaidTableIds = ref.watch(unpaidTablesByBranchProvider(branchId));
    final allTables = ref.watch(tableNotifierProvider);
    // Lọc bàn theo tên (không dấu, không phân biệt hoa thường)
    final List<DiningTable> tables =
        _searchKeyword.isEmpty
            ? allTables
            : allTables.where((table) {
              final tableName = _removeVietnameseDiacritics(table.name);
              final keyword = _removeVietnameseDiacritics(_searchKeyword);
              return tableName.contains(keyword);
            }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn bàn', style: Style.fontTitle),
        centerTitle: false,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          IconButton(
            onPressed: () {
              Routes.pushRightLeftConsumerFul(context, ScreenReservation());
            },
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
      body: RefreshIndicator(
        onRefresh: _loadTables,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          children: [
            const SizedBox(height: 8),
            _search(context),
            const SizedBox(height: 16),
            _buildTableGrid(context, tables, unpaidTableIds),
            const SizedBox(height: 24),
          ],
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bàn...',
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
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
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

  Widget _buildTableGrid(
    BuildContext context,
    List<DiningTable> tables,
    AsyncValue<Set<int>> unpaidTableIds,
  ) {
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

        final bool hasUnpaidOrders = unpaidTableIds.when(
          data: (ids) => ids.contains(table.id),
          loading: () => false,
          error: (_, __) => false,
        );

        return InkWell(
          onTap: () => _openTable(table, hasUnpaidOrders),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      hasUnpaidOrders
                          ? (Theme.of(context).brightness == Brightness.light
                              ? Colors.green.shade400
                              : Colors.green.shade500)
                          : (Theme.of(context).brightness == Brightness.light
                              ? Colors.grey.shade300
                              : Colors.grey.shade700),
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
                          table.name,
                          style: TextStyle(
                            color:
                                hasUnpaidOrders
                                    ? Colors.white
                                    : (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.black),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
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
                          const SizedBox(width: 6),
                          Icon(
                            Icons.person,
                            size: 14,
                            color:
                                hasUnpaidOrders
                                    ? Colors.white
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
                                      ? Colors.white
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

// // 1. Provider mới để tải tóm tắt order cho Dialog
// final _dialogOrderSummaryProvider =
//     FutureProvider.family<List<OrderItem>, int>((ref, tableId) async {
//   final orderApi = ref.watch(orderApiProvider);

//   // Lấy order (chỉ lấy order đầu tiên của bàn trong ngày)
//   final orders = await orderApi.fetchOrdersByTableIdToday(tableId);
//   if (orders.isEmpty) {
//     return []; // Không có order, trả về list rỗng
//   }
//   final order = orders.first;

//   // Lấy danh sách items của order đó
//   // final items = await orderApi.fetchOrderItems(order.id.toString());
//   // return items;
// });

// // 2. Widget AlertDialog
// class _ExistingOrderDialog extends ConsumerWidget {
//   final int tableId;
//   final String tableName;

//   const _ExistingOrderDialog({
//     required this.tableId,
//     required this.tableName,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch provider mới
//     final orderItemsAsync = ref.watch(_dialogOrderSummaryProvider(tableId));

//     return AlertDialog(
//       title: Text('Order của $tableName'),
//       content: Container(
//         // Đặt chiều cao cố định để dialog không bị nhảy size khi loading
//         height: 70,
//         child: orderItemsAsync.when(
//           data: (items) {
//             if (items.isEmpty) {
//               return const Center(child: Text('Bàn này chưa chọn món.'));
//             }
//             // Đếm tổng số lượng món
//             final totalQuantity =
//                 items.fold(0, (sum, item) => sum + item.quantity);
//             // Đếm số loại món
//             final totalItemTypes = items.length;

//             return Center(
//               child: Text(
//                 'Đã order $totalItemTypes loại món.\n(Tổng số lượng: $totalQuantity)',
//                 textAlign: TextAlign.center,
//                 style: Style.fontNormal,
//               ),
//             );
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (err, stack) => const Center(
//             child: Text('Lỗi tải chi tiết order.'),
//           ),
//         ),
//       ),
//       actionsAlignment: MainAxisAlignment.spaceBetween,
//       actions: [
//         // Nút Thanh Toán
//         TextButton(
//           onPressed: () {
//             // TODO: Thêm logic gọi API thanh toán ở đây
//             Navigator.of(context).pop(); // Đóng dialog
//             print('Yêu cầu thanh toán cho bàn $tableId');
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Đã gửi yêu cầu thanh toán cho $tableName')),
//             );
//           },
//           child: Text(
//             'Thanh Toán',
//             style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
//           ),
//         ),
//         // Nút Thêm Món
//         ElevatedButton(
//           onPressed: () {
//             // Đóng dialog VÀ chuyển sang màn hình Menu
//             Navigator.of(context).pop();
//             Routes.pushRightLeftConsumerFul(
//               context,
//               ScreenMenu(
//                 tableId: tableId,
//                 tableName: tableName,
//               ),
//             );
//           },
//           child: const Text('Thêm Món'),
//         ),
//       ],
//     );
//   }
// }
