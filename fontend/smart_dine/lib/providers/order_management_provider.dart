import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/order_management_API.dart';
import '../API/order_item_API.dart';
import '../API/menu_item_API.dart';
import '../models/order.dart';
import '../models/item.dart';
import 'user_session_provider.dart';

// Provider để lấy order với full items theo orderId  
final orderWithItemsProvider = FutureProvider.family<Order?, int>((ref, orderId) async {
  final api = ref.read(orderManagementApiProvider);
  final session = ref.read(userSessionProvider);
  
  // 1. Lấy thông tin cơ bản của order
  final order = await api.getOrderById(orderId);
  if (order == null) {
    return null;
  }

  // 2. Lấy order items từ API khác
  final orderItemAPI = OrderItemAPI();
  final items = await orderItemAPI.getOrderItemsByOrderId(orderId);
  
  // 3. Load tất cả menu items của company (ưu tiên lấy từ session, fallback từ order, cuối cùng = 1)
  final menuAPI = MenuItemAPI();
  final companyId = session.companyId ?? order.companyId ?? 1;
  final menuItems = await menuAPI.getMenuItemsByCompanyId(companyId);
  
  // Tạo map để lookup nhanh menu item theo ID
  final menuMap = <int, Item>{};
  for (final menuItem in menuItems) {
    if (menuItem.id != null) {
      menuMap[menuItem.id!] = menuItem;
    }
  }

  // 4. Map order items với thông tin menu và tính tổng tiền
  double totalAmount = 0.0;
  final orderItems = <OrderItem>[];
  for (final item in items) {
    final menuItem = menuMap[item.itemId];
    final itemPrice = menuItem?.price ?? 0.0;
    totalAmount += itemPrice * item.quantity;
    
    orderItems.add(OrderItem(
      id: item.id,
      orderId: item.orderId,
      itemId: item.itemId,
      quantity: item.quantity,
      itemPrice: itemPrice,
      itemName: menuItem?.name ?? 'Món ${item.itemId}',
      note: item.note,
      statusId: item.statusId,
      addedBy: item.addedBy,
      servedBy: item.servedBy,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
    ));
  }

  // 5. Trả về order với items và tổng tiền đã tính
  return order.copyWith(items: orderItems, totalAmount: totalAmount);
});

// Provider cho order management
final orderManagementProvider = StateNotifierProvider<OrderManagementNotifier, AsyncValue<List<Order>>>((ref) {
  return OrderManagementNotifier(
    ref.read(orderManagementApiProvider),
  );
});

// Provider cho orders theo branch ID (basic - chỉ thông tin order)
final ordersByBranchProvider = StateNotifierProvider.family<OrderManagementNotifier, AsyncValue<List<Order>>, int>((ref, branchId) {
  final notifier = OrderManagementNotifier(ref.read(orderManagementApiProvider));
  notifier.loadOrdersByBranchId(branchId);
  return notifier;
});

// Class để wrap order với metadata
class OrderWithMetadata {
  final Order order;
  final int itemsCount;
  
  OrderWithMetadata({
    required this.order, 
    required this.itemsCount,
  });
}

// Provider cho orders với đầy đủ items và totalAmount theo branch ID
final ordersWithItemsByBranchProvider = FutureProvider.family<List<OrderWithMetadata>, int>((ref, branchId) async {
  final api = ref.read(orderManagementApiProvider);
  final session = ref.read(userSessionProvider);
  
  // 1. Lấy danh sách orders cơ bản
  final orders = await api.getOrdersByBranchId(branchId);
  if (orders == null || orders.isEmpty) {
    return [];
  }

  // 2. Load menu items cho company  
  final companyId = session.companyId ?? 1;
  final menuAPI = MenuItemAPI();
  final menuItems = await menuAPI.getMenuItemsByCompanyId(companyId);
  
  // Tạo map để lookup nhanh menu item theo ID
  final menuMap = <int, Item>{};
  for (final menuItem in menuItems) {
    if (menuItem.id != null) {
      menuMap[menuItem.id!] = menuItem;
    }
  }

  // 3. Load items count và tính totalAmount cho từng order
  final List<OrderWithMetadata> ordersWithData = [];
  final orderItemAPI = OrderItemAPI();
  
  for (final order in orders) {
    if (order.id == null) continue;
    
    // Load order items để đếm và tính tiền
    final items = await orderItemAPI.getOrderItemsByOrderId(order.id!);
    
    // Tính totalAmount và itemsCount
    double totalAmount = 0.0;
    int itemsCount = items.length;
    
    for (final item in items) {
      final menuItem = menuMap[item.itemId];
      final itemPrice = menuItem?.price ?? 0.0;
      totalAmount += itemPrice * item.quantity;
    }
    
    // Tạo order với totalAmount
    final orderWithTotalAmount = order.copyWith(totalAmount: totalAmount);
    
    // Wrap với metadata
    final orderWithMetadata = OrderWithMetadata(
      order: orderWithTotalAmount,
      itemsCount: itemsCount,
    );
    
    ordersWithData.add(orderWithMetadata);
  }
  
  return ordersWithData;
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
            state = const AsyncValue.loading();
      final orders = await _api.getAllOrders();
      
            if (orders != null) {
                state = AsyncValue.data(orders);
      } else {
                state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
                  state = AsyncValue.error(error, stackTrace);
    }
  }

  // Load orders theo branch ID
  Future<void> loadOrdersByBranchId(int branchId) async {
    try {
            state = const AsyncValue.loading();
      final orders = await _api.getOrdersByBranchId(branchId);
      
            if (orders != null) {
                state = AsyncValue.data(orders);
      } else {
                state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
                  state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Order?> getOrderById(int orderId) async {
    try {
      return await _api.getOrderById(orderId);
    } catch (error) {
            return null;
    }
  }



  Future<List<int>?> getUnpaidTableIds() async {
    try {
      return await _api.getUnpaidOrderTableIdsToday();
    } catch (error) {
            return null;
    }
  }

  Future<List<Order>?> getOrdersByTableId(int tableId) async {
    try {
      return await _api.getOrdersByTableIdToday(tableId);
    } catch (error) {
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