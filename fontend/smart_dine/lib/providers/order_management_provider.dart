import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/order_management_API.dart';
import '../models/order.dart';

// Provider cho order management
final orderManagementProvider = StateNotifierProvider<OrderManagementNotifier, AsyncValue<List<Order>>>((ref) {
  return OrderManagementNotifier(
    ref.read(orderManagementApiProvider),
  );
});

// Provider cho orders theo branch ID
final ordersByBranchProvider = StateNotifierProvider.family<OrderManagementNotifier, AsyncValue<List<Order>>, int>((ref, branchId) {
  final notifier = OrderManagementNotifier(ref.read(orderManagementApiProvider));
  notifier.loadOrdersByBranchId(branchId);
  return notifier;
});

// Provider cho order statuses
final orderStatusProvider = StateNotifierProvider<OrderStatusNotifier, AsyncValue<List<OrderStatus>>>((ref) {
  return OrderStatusNotifier(
    ref.read(orderManagementApiProvider),
  );
});

class OrderManagementNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderManagementAPI _api;

  OrderManagementNotifier(this._api) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      print('🔄 OrderManagementProvider: Starting loadOrders()');
      state = const AsyncValue.loading();
      final orders = await _api.getAllOrders();
      
      print('📊 OrderManagementProvider: API returned ${orders?.length ?? 'null'} orders');
      
      if (orders != null) {
        print('✅ OrderManagementProvider: Setting data with ${orders.length} orders');
        state = AsyncValue.data(orders);
      } else {
        print('⚠️ OrderManagementProvider: API returned null, setting empty list');
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      print('❌ OrderManagementProvider: Error occurred: $error');
      print('📍 OrderManagementProvider: Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Load orders theo branch ID
  Future<void> loadOrdersByBranchId(int branchId) async {
    try {
      print('🔄 OrderManagementProvider: Starting loadOrdersByBranchId($branchId)');
      state = const AsyncValue.loading();
      final orders = await _api.getOrdersByBranchId(branchId);
      
      print('📊 OrderManagementProvider: API returned ${orders?.length ?? 'null'} orders for branch $branchId');
      
      if (orders != null) {
        print('✅ OrderManagementProvider: Setting data with ${orders.length} orders');
        state = AsyncValue.data(orders);
      } else {
        print('⚠️ OrderManagementProvider: API returned null, setting empty list');
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      print('❌ OrderManagementProvider: Error occurred: $error');
      print('📍 OrderManagementProvider: Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Order?> getOrderById(int orderId) async {
    try {
      return await _api.getOrderById(orderId);
    } catch (error) {
      print('Error getting order by id: $error');
      return null;
    }
  }

  Future<List<int>?> getUnpaidTableIds() async {
    try {
      return await _api.getUnpaidOrderTableIdsToday();
    } catch (error) {
      print('Error getting unpaid table ids: $error');
      return null;
    }
  }

  Future<List<Order>?> getOrdersByTableId(int tableId) async {
    try {
      return await _api.getOrdersByTableIdToday(tableId);
    } catch (error) {
      print('Error getting orders by table id: $error');
      return null;
    }
  }
}

class OrderStatusNotifier extends StateNotifier<AsyncValue<List<OrderStatus>>> {
  final OrderManagementAPI _api;

  OrderStatusNotifier(this._api) : super(const AsyncValue.loading()) {
    loadOrderStatuses();
  }

  Future<void> loadOrderStatuses() async {
    try {
      state = const AsyncValue.loading();
      final statuses = await _api.getAllOrderStatuses();
      
      if (statuses != null) {
        state = AsyncValue.data(statuses);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}