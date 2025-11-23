import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/providers/Item_provider.dart';
import 'package:mart_dine/providers/kitchen_order_provider.dart';
import 'package:mart_dine/providers/loading_provider.dart';
import 'package:mart_dine/providers/order_provider.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/widgets/loading.dart';

//Các trạng thái của món ăn
// enum OrderStatus { Duyệt, inProgress, completed, cancelled, soldOut }

class ScreenKitchen extends ConsumerStatefulWidget {
  final int? companyId;
  final int? branch;
  const ScreenKitchen({Key? key, this.companyId, this.branch})
    : super(key: key);

  @override
  ConsumerState<ScreenKitchen> createState() => _ScreenKitchenState();
}

class _ScreenKitchenState extends ConsumerState<ScreenKitchen>
    with SingleTickerProviderStateMixin {
  static const Map<int, String> _statusLabels = {
    1: 'Duyệt',
    2: 'Đang làm',
    3: 'Đã phục vụ',
    4: 'Hủy',
    5: 'Hết món',
    6: 'Chờ phục vụ',
  };

  static const Map<int, Color> _statusColors = {
    1: Color(0xFF2196F3),
    2: Color(0xFFFFA726),
    3: Color(0xFF43A047),
    4: Color(0xFFE53935),
    5: Color(0xFF757575),
    6: Color(0xFF8E24AA),
  };

  // Map để cache tên user theo userId
  final Map<int, String> _userNames = {};

  // Hàm lấy tên user theo id
  Future<String> _getUserName(int userId) async {
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    }
    try {
      // Gọi API lấy user theo id
      final response = await http.get(
        Uri.parse(
          'https://smartdine-backend-oq2x.onrender.com/api/users/get/$userId',
        ),
      );
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final fullName = userData['fullName'] ?? 'Unknown';
        _userNames[userId] = fullName;
        return fullName;
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    _userNames[userId] = 'Unknown';
    return 'Unknown';
  }

  //Update status order item
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

  //Ngày hôm nay
  DateTime get today => DateTime.now();
  //Sử dụng tabview
  late final TabController _tabController;
  //các tabs
  final tabs = const [
    Tab(text: 'Duyệt'),
    Tab(text: 'Đang làm'),
    Tab(text: 'Chờ phục vụ'),
    Tab(text: 'Đã phục vụ'),
    Tab(text: 'Hủy'),
    Tab(text: 'Hết món'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    Future.microtask(_loadAll);
  }

  //Load all
  Future<void> _loadAll() async {
    await _loadTodayOrders();
    await _loadItemsByCompanyId();
    await _loadOrders();
    await _loadTablesByBranchId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //Lấy danh sách order trong ngày
  Future<void> _loadTodayOrders() async {
    await ref
        .read(kitchenOrderNotifierProvider.notifier)
        .loadTodayOrders(branchId: widget.branch ?? 1);
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

  //Load items by companyId
  Future<void> _loadItemsByCompanyId() async {
    await ref
        .read(itemNotifierProvider.notifier)
        .loadMenuItemsByCompanyId(widget.companyId ?? 1);
  }

  //Load orders by branchId
  Future<void> _loadOrders() async {
    await ref
        .read(orderNotifierProvider.notifier)
        .loadOrdersByBranchId(widget.branch ?? 1);
  }

  //Load tables by branchId
  Future<void> _loadTablesByBranchId() async {
    await ref
        .read(tableNotifierProvider.notifier)
        .loadTables(widget.branch ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(kitchenOrderNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Phòng Bếp ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              '(${today.toLocal().toString().split(' ')[0]})',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: tabs,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: orderState.when(
                    data: (orders) {
                      // 🔥 Sắp xếp tất cả orders theo thời gian tạo (mới nhất → cũ nhất)
                      final sortedOrders = [...orders]
                        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                      return TabBarView(
                        controller: _tabController,
                        children:
                            _statusIds
                                .map(
                                  (status) => RefreshIndicator(
                                    onRefresh: _loadAll,
                                    child: buildList(
                                      sortedOrders
                                          .where((o) => o.statusId == status)
                                          .toList(),
                                    ),
                                  ),
                                )
                                .toList(),
                      );
                    },
                    loading:
                        () => RefreshIndicator(
                          onRefresh: _loadAll,
                          child: _buildLoadingList(),
                        ),
                    error:
                        (error, __) => RefreshIndicator(
                          onRefresh: _loadAll,
                          child: _buildErrorList(error),
                        ),
                  ),
                ),
              ],
            ),
            ref.watch(isLoadingNotifierProvider)
                ? Positioned.fill(child: Loading(index: 1))
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  List<int> get _statusIds => const [1, 2, 6, 3, 4, 5];

  Widget buildList(List<OrderItem> orders) {
    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Chưa có món nào cho hôm nay.')),
          ),
        ],
      );
    }

    /// Sắp xếp giảm dần theo thời gian tạo (mới nhất lên đầu):
    //Sắp xếp giảm dần theo thời gian tạo (mới nhất lên đầu)
    orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildOrderCard(context, orders[index]),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderItem item) {
    final theme = Theme.of(context);
    final statusColor =
        _statusColors[item.statusId] ?? theme.colorScheme.primary;
    final statusLabel = _statusLabels[item.statusId] ?? 'Khác';
    final note = item.note?.trim();
    final tableName = _tableNameForOrder(item.orderId);

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
                        _itemName(item),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$tableName', style: Style.fontCaption),
                      if (item.addedBy != null) ...[
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _getUserName(item.addedBy!),
                          builder: (context, snapshot) {
                            final userName = snapshot.data ?? 'Đang tải...';
                            return Text(
                              'Người order: $userName',
                              style: Style.fontCaption.copyWith(
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ],
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Tạo lúc ${_formatTime(item.createdAt)}',
                  style: Style.fontCaption,
                ),
                const Spacer(),
                Text('Mã đơn: ${item.orderId}', style: Style.fontCaption),
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
      case 1:
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () => _handleStatusChange(context, item, 2, 'Duyệt'),
              style: FilledButton.styleFrom(
                backgroundColor: statusColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Duyệt'),
            ),
            OutlinedButton(
              onPressed: () => _handleStatusChange(context, item, 5, 'Hết món'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Hết món'),
            ),
          ],
        );
      case 2:
        return Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed:
                () => _handleStatusChange(context, item, 6, 'Đã làm xong'),
            style: FilledButton.styleFrom(
              backgroundColor: statusColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đã làm xong'),
          ),
        );
      case 6:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chờ phục vụ', style: caption.copyWith(color: statusColor)),
          ],
        );
      case 3:
        return Align(
          alignment: Alignment.centerLeft,
          child: Text('Đã phục vụ', style: caption),
        );
      case 4:
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Đơn đã hủy',
            style: caption.copyWith(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case 5:
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Đã hết món',
            style: caption.copyWith(color: Colors.grey.shade700),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static String _formatTime(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildLoadingList() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorList(Object error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Không tải được danh sách món ăn.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('$error'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTodayOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
