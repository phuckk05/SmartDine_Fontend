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
            state = [];
    }
  }

  // Fetch orders by table ID for today
  Future<void> fetchByTableIdToday(int tableId) async {
    try {
      final orders = await orderApi.fetchOrdersByTableIdToday(tableId);
      state = orders;
    } catch (e) {
            state = [];
    }
  }

  // Fetch unpaid table IDs for today
  Future<List<int>> fetchUnpaidTableIdsToday() async {
    try {
      return await orderApi.fetchUnpaidTableIdsToday();
    } catch (e) {
            return [];
    }
  }

  // Get order by ID
  Future<Order?> getById(int id) async {
    try {
      return await orderApi.getOrderById(id);
    } catch (e) {
            return null;
    }
  }

  Future<void> loadOrdersByBranchId(int branchId) async {
    final orders = await orderApi.getOrdersByBranchId(branchId);
    state = orders;
  }

  Set<Order> build() {
    return const {};
  }

  //Kiểm tra orderId nếu có lấy tableOrderId
  int? checkOrderExists(int orderId) {
        for (final order in state) {
            // ignore: unrelated_type_equality_checks
      if (order.id == orderId) {
        return order.tableId;
      }
    }
    return null;
  }
}

// Provider for OrderProvider
final orderNotifierProvider = StateNotifierProvider<OrderProvider, List<Order>>(
  (ref) {
    final orderApi = ref.watch(orderApiProvider);
    return OrderProvider(orderApi);
  },
);
