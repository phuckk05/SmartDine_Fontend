import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/API/order_API.dart';
import 'package:mart_dine/widgets/appbar.dart';

class ScreenHistoryService extends ConsumerStatefulWidget {
  final int? branchId;
  final int? userId;
  const ScreenHistoryService({super.key, this.branchId, this.userId});

  @override
  ConsumerState<ScreenHistoryService> createState() =>
      _ScreenHistoryServiceState();
}

class _ScreenHistoryServiceState extends ConsumerState<ScreenHistoryService> {
  // Provider to load all orders for a given userId
  static final ordersByUserProvider = FutureProvider.family<List<Order>, int>((
    ref,
    userId,
  ) async {
    final orderApi = ref.watch(orderApiProvider);
    // Fetch all orders and filter by userId (server may not provide user-specific endpoint)
    final all = await orderApi.fetchOrders();
    return all.where((o) => o.userId == userId).toList();
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCus(
        title: 'Lịch sử dịch vụ',
        isCanpop: true,
        isButtonEnabled: true,
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Invalidate provider to reload
            final userId = widget.userId ?? 1;
            ref.invalidate(ordersByUserProvider(userId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Builder(
                  builder: (context) {
                    final userId = widget.userId ?? 1;
                    final ordersAsync = ref.watch(ordersByUserProvider(userId));
                    return ordersAsync.when(
                      data: (orders) {
                        if (orders.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Không có lịch sử dịch vụ cho người dùng này.',
                            ),
                          );
                        }
                        return _buildOrderList(orders);
                      },
                      loading:
                          () => const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      error:
                          (err, stack) => Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text('Lỗi khi tải lịch sử: $err'),
                          ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Widget
  Widget _buildOrderList(List<Order> orders) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final o = orders[index];
        final date = o.createdAt.toLocal().toString().split('.').first;
        return Card(
          child: ListTile(
            title: Text('Order #${o.id} - Bàn ${o.tableId}'),
            subtitle: Text('Ngày: $date\nTrạng thái: ${o.statusId}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: open order detail if needed
            },
          ),
        );
      },
    );
  }
}
