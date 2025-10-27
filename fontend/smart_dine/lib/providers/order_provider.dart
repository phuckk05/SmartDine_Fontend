import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/order_API.dart';
import 'package:mart_dine/models/order.dart';

class OrderNotifier extends StateNotifier<List<Order>> {
  final OrderApi orderApi;
  OrderNotifier(this.orderApi) : super([]);

  Future<void> loadOrdersByBranchId(int branchId) async {
    final orders = await orderApi.getOrderByBranchId(branchId);
    state = orders;
  }

  Set<Order> build() {
    return const {};
  }

  //Kiểm tra orderId nếu có lấy tableOrderId
  int? checkOrderExists(int orderId) {
    print('Checking existence for order ID: $orderId');
    for (final order in state) {
      print('Checking order ID: ${order.id} against $orderId');
      // ignore: unrelated_type_equality_checks
      if (order.id == orderId) {
        return order.tableId;
      }
    }
    return null;
  }
}

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, List<Order>>(
  (ref) {
    return OrderNotifier(ref.watch(orderApiProvider));
  },
);
