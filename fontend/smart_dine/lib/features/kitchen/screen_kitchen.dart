import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/providers/kitchen_order_provider.dart';

//Các trạng thái của món ăn
// enum OrderStatus { Duyệt, inProgress, completed, cancelled, soldOut }

class ScreenKitchen extends ConsumerStatefulWidget {
  const ScreenKitchen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenKitchen> createState() => _ScreenKitchenState();
}

class _ScreenKitchenState extends ConsumerState<ScreenKitchen>
    with SingleTickerProviderStateMixin {
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
    Future.microtask(_loadTodayOrders);
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
        .loadTodayOrders(branchId: 1);
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(kitchenOrderNotifierProvider);

    return Scaffold(
      appBar: AppBar(
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
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Icon(Icons.notifications),
          SizedBox(width: 16),
          Icon(Icons.settings),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
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
                data:
                    (orders) => TabBarView(
                      controller: _tabController,
                      children:
                          _statusIds
                              .map(
                                (status) => RefreshIndicator(
                                  onRefresh: _loadTodayOrders,
                                  child: buildList(
                                    orders
                                        .where(
                                          (order) => order.statusId == status,
                                        )
                                        .toList(),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                loading:
                    () => RefreshIndicator(
                      onRefresh: _loadTodayOrders,
                      child: _buildLoadingList(),
                    ),
                error:
                    (error, __) => RefreshIndicator(
                      onRefresh: _loadTodayOrders,
                      child: _buildErrorList(error),
                    ),
              ),
            ),
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
            child: Text('Chưa có món nào cho hôm nay.'),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = orders[index];
        return ListTile(
          title: Text('Order Item ${item.id}'),
          subtitle: Text('Order: ${item.orderId} · SL: ${item.quantity}'),
          trailing: Text('Trạng thái: ${item.statusId}'),
        );
      },
    );
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
