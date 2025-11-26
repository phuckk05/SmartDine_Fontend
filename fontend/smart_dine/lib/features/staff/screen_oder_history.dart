import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/API_staff/order_API.dart';
import 'package:mart_dine/API_staff/order_item_API.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/model_staff/item.dart';
import 'package:mart_dine/model_staff/order.dart';
import 'package:mart_dine/model_staff/order_item.dart';
import 'package:mart_dine/provider_staff/menu_item_provider.dart';
import 'package:mart_dine/provider_staff/table_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart';

class ScreenOrderHistory extends ConsumerStatefulWidget {
  final int? branchId;
  const ScreenOrderHistory({super.key, this.branchId});

  @override
  ConsumerState<ScreenOrderHistory> createState() => _ScreenOrderHistoryState();
}

class _ScreenOrderHistoryState extends ConsumerState<ScreenOrderHistory> {
  late Future<List<Order>> _ordersFuture = Future.value(const <Order>[]);
  final Map<int, Future<List<OrderItem>>> _orderItemsFutures = {};
  final Map<int, String> _userNames = {};
  int? _branchId;
  int? _companyId;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    final session = ref.read(userSessionProvider);
    _branchId = widget.branchId ?? session.currentBranchId ?? 1;
    _companyId = session.companyId ?? 1;

    await Future.wait([
      ref.read(tableNotifierProvider.notifier).loadTables(_branchId!),
      ref.read(menuNotifierProvider.notifier).loadMenusByCompanyId(_companyId!),
    ]);

    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  Future<List<Order>> _fetchOrders() async {
    return ref.read(orderApiProvider).getOrdersByBranchId(_branchId ?? 1);
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
    await _ordersFuture;
  }

  Future<List<OrderItem>> _getOrderItems(int orderId) {
    return _orderItemsFutures.putIfAbsent(orderId, () async {
      return ref.read(orderItemApiProvider).getOrderItemsByOrderId(orderId);
    });
  }

  Future<String> _getUserName(int userId) async {
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://smartdine-backend-oq2x.onrender.com/api/users/get/$userId',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final name = (data['fullName'] ?? 'Không rõ').toString();
        _userNames[userId] = name;
        return name;
      }
    } catch (_) {}

    _userNames[userId] = 'Không rõ';
    return 'Không rõ';
  }

  String _tableName(int tableId) {
    final tableName = ref
        .read(tableNotifierProvider.notifier)
        .getTableNameById(tableId);
    return tableName ?? 'Bàn #$tableId';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  void _showOrderDetails(Order order) async {
    final items = await _getOrderItems(order.id);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final menuItems = ref.read(menuNotifierProvider);
        final menuMap = {
          for (final item in menuItems)
            if (item.id != null) item.id!: item,
        };
        final totalAmount = items.fold<double>(0, (sum, item) {
          final menuItem = menuMap[item.itemId];
          final price = menuItem?.price ?? 0;
          return sum + price * item.quantity;
        });

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Order #${order.id}', style: Style.fontTitle),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Bàn: ${_tableName(order.tableId)}'),
              const SizedBox(height: 4),
              Text('Thời gian: ${_formatDate(order.createdAt)}'),
              const Divider(height: 24),
              Flexible(
                child:
                    items.isEmpty
                        ? const Center(child: Text('Order chưa có món.'))
                        : ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final menuItem =
                                menuMap[item.itemId] ??
                                Item(
                                  id: item.itemId,
                                  companyId: _companyId ?? 0,
                                  name: 'Món #${item.itemId}',
                                  price: 0,
                                  statusId: 1,
                                );
                            final subtotal = menuItem.price * item.quantity;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(menuItem.name),
                              subtitle: Text('${item.quantity} phần'),
                              trailing: Text(
                                _formatCurrency(subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemCount: items.length,
                        ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _formatCurrency(totalAmount),
                    style: Style.fontTitleMini,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatCurrency(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()} đ';
  }

  Widget _buildOrderCard(Order order) {
    return FutureBuilder<List<OrderItem>>(
      future: _getOrderItems(order.id),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <OrderItem>[];
        final totalQuantity = items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            onTap: () => _showOrderDetails(order),
            title: Text(_tableName(order.tableId)),
            subtitle: FutureBuilder<String>(
              future: _getUserName(order.userId),
              builder: (context, userSnapshot) {
                final userName = userSnapshot.data ?? 'Đang tải...';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nhân viên: $userName'),
                    Text('Thời gian: ${_formatDate(order.createdAt)}'),
                    Text('Tổng món: $totalQuantity'),
                  ],
                );
              },
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Order ID'),
                Text(
                  '#${order.id}',
                  style: Style.fontTitleMini.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử order', style: Style.fontTitle),
        centerTitle: false,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Không tải được lịch sử order.'),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? const <Order>[];
          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Chưa có order nào.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: orders.length,
              itemBuilder: (context, index) => _buildOrderCard(orders[index]),
            ),
          );
        },
      ),
    );
  }
}
