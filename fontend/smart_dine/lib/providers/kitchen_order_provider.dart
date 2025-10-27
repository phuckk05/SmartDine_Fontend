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
      print('Kitchen orders fetched: ${orders.length}');
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print('Kitchen orders load failed: $error');
      state = AsyncValue.error(error, stackTrace);
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
