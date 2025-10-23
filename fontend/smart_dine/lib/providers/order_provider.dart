import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/API/order_API.dart';

class OrderProvider extends StateNotifier<List<Order>> {
  final OrderAPI orderApi;

  OrderProvider(this.orderApi) : super([]);

  // Fetch all orders
  Future<void> fetchAll() async {
    try {
      final orders = await orderApi.fetchOrders();
      state = orders;
    } catch (e) {
      print('Error fetching orders: $e');
      state = [];
    }
  }

  // Fetch orders by table ID for today
  Future<void> fetchByTableIdToday(int tableId) async {
    try {
      final orders = await orderApi.fetchOrdersByTableIdToday(tableId);
      state = orders;
    } catch (e) {
      print('Error fetching orders for table $tableId: $e');
      state = [];
    }
  }

  // Fetch unpaid table IDs for today
  Future<List<int>> fetchUnpaidTableIdsToday() async {
    try {
      return await orderApi.fetchUnpaidTableIdsToday();
    } catch (e) {
      print('Lỗi ko lấy đ ược: $e');
      return [];
    }
  }

  // Get order by ID
  Future<Order?> getById(int id) async {
    try {
      return await orderApi.getOrderById(id);
    } catch (e) {
      print('Error fetching order $id: $e');
      return null;
    }
  }
}

// Provider for OrderProvider
final orderNotifierProvider = StateNotifierProvider<OrderProvider, List<Order>>(
  (ref) {
    final orderApi = ref.watch(orderApiProvider);
    return OrderProvider(orderApi);
  },
);
