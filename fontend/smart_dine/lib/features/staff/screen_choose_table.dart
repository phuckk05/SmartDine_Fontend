import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/API_staff/order_API.dart';
import 'package:mart_dine/API_staff/order_item_API.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/cashier/screen_payment.dart';
import 'package:mart_dine/features/revervation/screen_reservation.dart';
import 'package:mart_dine/features/staff/screen_menu.dart';
import 'package:mart_dine/features/staff/screen_notifications.dart';
import 'package:mart_dine/features/staff/screen_settings.dart';
import 'package:mart_dine/model_staff/order.dart';
import 'package:mart_dine/model_staff/order_item.dart';
import 'package:mart_dine/model_staff/table.dart';
import 'package:mart_dine/provider_staff/table_provider.dart';
import 'package:mart_dine/provider_staff/user_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart';
import 'package:mart_dine/routes.dart';

class ScreenChooseTable extends ConsumerStatefulWidget {
  final int? branchId;
  const ScreenChooseTable({super.key, this.branchId});

  @override
  ConsumerState<ScreenChooseTable> createState() => _ScreenChooseTableState();
}

class _ScreenChooseTableState extends ConsumerState<ScreenChooseTable> {
  // Search
  final TextEditingController _searchController = TextEditingController();

  bool _isDisposed = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTables();
      }
    });
  }

  //Load tables
  Future<void> _loadTables() async {
    if (_isDisposed) return;
    final branchId = widget.branchId ?? 1;
    try {
      await ref.read(tableNotifierProvider.notifier).loadTables(branchId);
      if (_isDisposed) return;
      ref.invalidate(unpaidTablesByBranchProvider(branchId));
    } catch (e) {
      // Handle error silently
      print('Error loading tables: $e');
    }
  }

  Future<void> _openTable(DiningTable table, bool hasUnpaidOrders) async {
    if (!mounted) return;

    // Kiểm tra trạng thái bàn để quyết định hành động
    final unpaidTableStatus = ref.read(
      unpaidTablesByBranchProvider(widget.branchId ?? 1),
    );
    final tableStatus = unpaidTableStatus.when(
      data: (statusMap) => statusMap[table.id],
      loading: () => null,
      error: (_, __) => null,
    );

    // Nếu bàn có trạng thái yêu cầu thanh toán (status 4), kiểm tra role để quyết định hành động
    if (tableStatus == 4) {
      if (!mounted) return;

      // Lấy thông tin user hiện tại để kiểm tra role
      final user = ref.read(userNotifierProvider);
      final session = ref.read(userSessionProvider);
      final userRole = user?.role ?? session.userRole;
      if (userRole == 6) {
        // Role 2 là thu ngân - chuyển đến màn hình thanh toán
        // Cần lấy thông tin order và orderItems trước
        Order? currentOrder;
        List<OrderItem> currentOrderItems = [];

        try {
          final orderApi = ref.read(orderApiProvider);
          final orders = await orderApi.fetchOrdersByTableIdToday(table.id);

          if (orders.isNotEmpty) {
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            // Find the most recent active order for this table.
            for (final order in orders) {
              if (order.statusId == 4) {
                currentOrder = order;
                break;
              }
            }

            if (currentOrder != null) {
              final orderItemApi = ref.read(orderItemApiProvider);
              final items = await orderItemApi.getOrderItemsByOrderId(
                currentOrder.id,
              );
              currentOrderItems = List<OrderItem>.from(items);

              if (mounted) {
                Routes.pushRightLeftConsumerFul(
                  context,
                  ScreenPayment(
                    tableId: table.id,
                    tableName: table.name,
                    order: currentOrder,
                    orderItems: currentOrderItems,
                    companyId: currentOrder.companyId,
                  ),
                );
              }
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không thể tải thông tin order: $e')),
            );
          }
        }
      } else {
        // Role khác (nhân viên) - hiển thị dialog thông báo thu ngân
        try {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Text('Thông báo thu ngân'),
                content: Text(
                  'Bàn ${table.name} đang yêu cầu thanh toán. Vui lòng thông báo cho thu ngân xử lý.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          );
        } catch (e) {
          // Widget unmounted, ignore
        }
      }
      return;
    }

    Order? initialOrder;
    List<OrderItem> initialItems = const <OrderItem>[];

    if (hasUnpaidOrders) {
      bool dialogOpened = false;
      if (mounted) {
        dialogOpened = true;
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } catch (e) {
          // Widget unmounted, ignore
        }
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

            // Không còn chuyển đến thanh toán cho status 4 ở đây nữa
          } else {
            // No active orders (e.g., all orders are paid - statusId == 3).
            initialOrder = null;
            initialItems = const <OrderItem>[];
          }
        }
      } catch (e) {
        if (mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không tải được order hiện tại: $e')),
            );
          } catch (e) {
            // Widget unmounted, ignore
          }
        }
      } finally {
        if (mounted && dialogOpened) {
          try {
            Navigator.of(context, rootNavigator: true).pop();
          } catch (e) {
            // Widget unmounted, ignore
          }
        }
      }
    }

    if (!mounted) return;

    try {
      final session = ref.read(userSessionProvider);
      final selectedBranchId = widget.branchId ?? session.currentBranchId ?? 1;
      final sessionCompanyId = session.companyId ?? 1;
      final sessionUserId = session.userId ?? 1;

      Routes.pushRightLeftConsumerFul(
        context,
        ScreenMenu(
          tableId: table.id,
          tableName: table.name,
          branchId: selectedBranchId,
          companyId: sessionCompanyId,
          userId: sessionUserId,
          initialOrder: initialOrder,
          initialOrderItems: initialItems,
        ),
      );
    } catch (e) {
      // Widget unmounted, ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchId = widget.branchId ?? 1;
    final unpaidTableStatus = ref.watch(unpaidTablesByBranchProvider(branchId));
    final allTables = ref.watch(tableNotifierProvider);
    final searchKeyword = _searchController.text;
    // Lọc bàn theo tên (không dấu, không phân biệt hoa thường)
    final List<DiningTable> tables =
        searchKeyword.isEmpty
            ? allTables
            : allTables.where((table) {
              final tableName = _removeVietnameseDiacritics(table.name);
              final keyword = _removeVietnameseDiacritics(searchKeyword);
              return tableName.contains(keyword);
            }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn bàn', style: Style.fontTitle),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
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
            onPressed: () {
              Routes.pushRightLeftConsumerFul(
                context,
                ScreenNotifications(branchId: widget.branchId),
              );
            },
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
            _buildTableGrid(context, tables, unpaidTableStatus),
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
                // Trigger rebuild by using controller text directly in build
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
    AsyncValue<Map<int, int>> unpaidTableStatus,
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

        final int? tableStatus = unpaidTableStatus.when(
          data: (statusMap) => statusMap[table.id],
          loading: () => null,
          error: (_, __) => null,
        );

        final bool hasUnpaidOrders = tableStatus != null;
        final bool isPaymentRequested = tableStatus == 4;

        return InkWell(
          onTap: () => _openTable(table, hasUnpaidOrders),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      hasUnpaidOrders
                          ? (isPaymentRequested
                              ? Colors.orange.shade400
                              : Colors.green.shade400)
                          : Colors.grey.shade300,
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
