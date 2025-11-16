import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/providers/kitchen_order_provider.dart';
import 'package:mart_dine/providers/loading_provider.dart';
import 'package:mart_dine/providers/Item_provider.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/providers/order_provider.dart';
import 'package:mart_dine/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ScreenNotifications extends ConsumerStatefulWidget {
  final int? branchId;
  const ScreenNotifications({super.key, this.branchId});

  @override
  ConsumerState<ScreenNotifications> createState() =>
      _ScreenNotificationsState();
}

class _ScreenNotificationsState extends ConsumerState<ScreenNotifications> {
  static const Map<int, String> _statusLabels = {
    1: 'PENDING',
    2: 'COOKING',
    3: 'SERVED',
    6: 'COOKED',
  };

  static final Map<int, Color> _statusColors = {
    1: Color(0xFF2196F3),
    2: Color(0xFFFFA726),
    3: Color(0xFF43A047),
    6: Color(0xFF8E24AA),
  };

  String _selectedStatus = 'Tất cả';
  final List<String> _statusOptions = [
    'Tất cả',
    'PENDING',
    'COOKING',
    'COOKED',
    'SERVED',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    await ref
        .read(kitchenOrderNotifierProvider.notifier)
        .loadTodayOrders(branchId: widget.branchId ?? 1);
  }

  String _itemName(OrderItem item) {
    return ref
            .read(itemNotifierProvider.notifier)
            .checkItemExists(item.itemId) ??
        'Món #${item.itemId}';
  }

  String _tableNameForOrder(int orderId) {
    final tableId = ref
        .read(orderNotifierProvider.notifier)
        .checkOrderExists(orderId);
    final name = ref
        .read(tableNotifierProvider.notifier)
        .getTableNameById(tableId);
    if (name != null) return name;
    if (tableId != null) return 'Bàn #$tableId';
    return 'Bàn chưa xác định';
  }

  void _handleStatusChange(
    BuildContext context,
    OrderItem item,
    int newStatus,
    String label,
  ) async {
    ref.read(isLoadingNotifierProvider.notifier).toggle(true);
    final success = await ref
        .read(kitchenOrderNotifierProvider.notifier)
        .updateOrderItemStatus(item.id!, newStatus);
    if (success) {
      Constrats.showThongBao(context, 'Đã cập nhật trạng thái sang "$label"');
    } else {
      Constrats.showThongBao(context, 'Cập nhật trạng thái thất bại');
    }
    ref.read(isLoadingNotifierProvider.notifier).toggle(false);
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(kitchenOrderNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo món', style: Style.fontTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              items:
                  _statusOptions
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              value: _selectedStatus,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedStatus = value;
                });
              },
              customButton: Row(
                children: [
                  Text(
                    _selectedStatus,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
              dropdownStyleData: DropdownStyleData(
                offset: const Offset(0, 0),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                maxHeight: 240,
                width: 120,
              ),
              menuItemStyleData: const MenuItemStyleData(height: 44),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadData,
              child: orderState.when(
                data: (orders) => _buildOrderList(orders),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, __) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Không tải được danh sách món ăn.'),
                          const SizedBox(height: 8),
                          Text('$error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
            ref.watch(isLoadingNotifierProvider)
                ? Positioned.fill(child: Loading(index: 1))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderItem> orders) {
    // Filter orders based on selected status
    final filteredOrders =
        _selectedStatus == 'Tất cả'
            ? orders
            : orders.where((item) {
              final statusLabel = _statusLabels[item.statusId] ?? 'Khác';
              return statusLabel == _selectedStatus;
            }).toList();

    if (filteredOrders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Chưa có món nào cần thông báo.')),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filteredOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder:
          (context, index) => _buildOrderCard(context, filteredOrders[index]),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderItem item) {
    final theme = Theme.of(context);
    final statusColor =
        _statusColors[item.statusId] ?? theme.colorScheme.primary;
    final statusLabel = _statusLabels[item.statusId] ?? 'Khác';
    final note = item.note?.trim();
    final tableName = _tableNameForOrder(item.orderId);
    final itemName = _itemName(item);

    return Card(
      elevation: 0.5,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: statusColor.withOpacity(0.12),
                  ),
                  child: Center(
                    child: Text(
                      'x${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$tableName', style: Style.fontCaption),
                      const SizedBox(height: 4),
                      Text(
                        'Thời gian đặt: ${_formatTime(item.createdAt)}',
                        style: Style.fontCaption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Ghi chú: $note', style: Style.fontCaption),
              ),
            ],
            const SizedBox(height: 14),
            _buildActionArea(context, item, statusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea(
    BuildContext context,
    OrderItem item,
    Color statusColor,
  ) {
    final caption = Style.fontCaption;

    switch (item.statusId) {
      case 6: // COOKED - có thể xác nhận phục vụ
        return Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed:
                () => _handleStatusChange(context, item, 3, 'Đã phục vụ'),
            style: FilledButton.styleFrom(
              backgroundColor: statusColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xác nhận phục vụ'),
          ),
        );
      case 3: // SERVED
        return Align(
          alignment: Alignment.centerLeft,
          child: Text('Đã phục vụ', style: caption),
        );
      default:
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(_statusLabels[item.statusId] ?? 'Khác', style: caption),
        );
    }
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final local = time.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final timeDate = DateTime(local.year, local.month, local.day);

    if (timeDate == today) {
      // Today - show only time
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      // Other days - show date and time
      final day = local.day.toString().padLeft(2, '0');
      final month = local.month.toString().padLeft(2, '0');
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$day/$month $hour:$minute';
    }
  }
}
