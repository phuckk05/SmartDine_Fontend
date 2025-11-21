import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/kitchen_API.dart';
import 'package:mart_dine/models/order_item.dart';

class KitchenOrderNotifier extends StateNotifier<AsyncValue<List<OrderItem>>> {
  KitchenOrderNotifier(this._api) : super(const AsyncValue.data(<OrderItem>[]));

  final KitchenApi _api;

  Future<void> loadTodayOrders({required int branchId}) async {
    state = const AsyncValue.loading();
    try {
      final orders = await _api.getPendingOrderItems(branchId);
      // Log fetch results to help diagnose empty UI states.
      // ignore: avoid_print
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      //kitchen- 3
      // ignore: avoid_print
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadOrderItemsByBranch({required int branchId}) async {
    state = const AsyncValue.loading();
    try {
      final orders = await _api.getOrderItemsByBranch(branchId);
      // ignore: avoid_print
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      // ignore: avoid_print
      state = AsyncValue.error(error, stackTrace);
    }
  }

  //Cập nhật trạng thái order item
  Future<bool> updateOrderItemStatus(int orderItemId, int status) async {
    try {
      final updatedItem = await _api.updateOrderItemStatus(orderItemId, status);
      final currentOrders = state.asData?.value;

      if (currentOrders != null) {
        final updatedOrders = [
          for (final order in currentOrders)
            if (order.id == orderItemId) updatedItem else order,
        ];

        state = AsyncValue.data(updatedOrders);
      }

      return true;
    } catch (e) {
      // ignore: avoid_print
      return false;
    }
  }
}

final kitchenOrderNotifierProvider =
    StateNotifierProvider<KitchenOrderNotifier, AsyncValue<List<OrderItem>>>((
      ref,
    ) {
      final api = ref.watch(kitchenApiProvider);
      return KitchenOrderNotifier(api);
    });
