import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/phongbep_models.dart';

/// Provider cho danh sách tất cả orders
final ordersProvider = StateProvider<List<KitchenOrder>>((ref) {
  // Dữ liệu mẫu - trong thực tế sẽ load từ API
  return [
    KitchenOrder.create(
      dishName: 'Bánh mỳ',
      createdTime: '12:53',
      tableNumber: 'b-3',
    ),
    KitchenOrder.create(
      dishName: 'Phở bò',
      createdTime: '13:15',
      tableNumber: 'a-5',
    ),
    KitchenOrder.create(
      dishName: 'Cơm gà',
      createdTime: '13:20',
      tableNumber: 'c-2',
    ),
    KitchenOrder.create(
      dishName: 'Bún chả',
      createdTime: '11:30',
      tableNumber: 'a-1',
    ),
    KitchenOrder.create(
      dishName: 'Bánh xèo',
      createdTime: '11:45',
      tableNumber: 'b-7',
    ),
    KitchenOrder.create(
      dishName: 'Mì xào',
      createdTime: '12:15',
      tableNumber: 'c-5',
    ),
    KitchenOrder.create(
      dishName: 'Hủ tiếu',
      createdTime: '12:00',
      tableNumber: 'd-4',
    ),
    KitchenOrder.create(
      dishName: 'Mì Quảng',
      createdTime: '12:10',
      tableNumber: 'c-8',
    ),
    KitchenOrder.create(
      dishName: 'Gỏi cuốn',
      createdTime: '10:50',
      tableNumber: 'b-2',
    ),
    KitchenOrder.create(
      dishName: 'Bún bò Huế',
      createdTime: '09:30',
      tableNumber: 'a-8',
    ),
  ];
});

/// Provider cho tab đang được chọn (0: Chưa làm, 1: Đã làm, 2: Hết món, 3: Đã hủy)
final selectedTabProvider = StateProvider<int>((ref) => 0);

/// Provider cho search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider cho filtered orders dựa trên tab và search
final filteredOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final orders = ref.watch(ordersProvider);
  final selectedTab = ref.watch(selectedTabProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  // Lọc theo status dựa trên tab
  OrderStatus statusFilter;
  switch (selectedTab) {
    case 0:
      statusFilter = OrderStatus.pending;
      break;
    case 1:
      statusFilter = OrderStatus.completed;
      break;
    case 2:
      statusFilter = OrderStatus.outOfStock;
      break;
    case 3:
      statusFilter = OrderStatus.cancelled;
      break;
    default:
      statusFilter = OrderStatus.pending;
  }

  List<KitchenOrder> filtered =
      orders.where((order) => order.status == statusFilter).toList();

  // Nếu đang ở tab "Đã làm", chỉ hiển thị món chưa lấy
  if (selectedTab == 1) {
    filtered = filtered.where((order) => !order.isPickedUp).toList();
  }

  // Lọc theo search query
  if (searchQuery.isNotEmpty) {
    filtered =
        filtered.where((order) {
          final lowerQuery = searchQuery.toLowerCase();
          return order.dishName.toLowerCase().contains(lowerQuery) ||
              order.tableNumber.toLowerCase().contains(lowerQuery);
        }).toList();
  }

  return filtered;
});

/// Provider đếm số lượng orders theo từng status
final ordersCountByStatusProvider = Provider<Map<OrderStatus, int>>((ref) {
  final orders = ref.watch(ordersProvider);

  final Map<OrderStatus, int> counts = {};
  for (final status in OrderStatus.values) {
    counts[status] = orders.where((order) => order.status == status).length;
  }

  // Đếm số món đã làm nhưng chưa lấy
  counts[OrderStatus.completed] =
      orders
          .where(
            (order) =>
                order.status == OrderStatus.completed && !order.isPickedUp,
          )
          .length;

  return counts;
});

/// Provider cho pending orders (chưa làm)
final pendingOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((order) => order.status == OrderStatus.pending).toList();
});

/// Provider cho completed orders đang chờ lấy
final waitingForPickupOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((order) => order.isWaitingForPickup).toList();
});
