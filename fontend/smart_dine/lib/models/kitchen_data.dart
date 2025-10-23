import 'kitchen_order.dart';
import 'kitchen_order_tinhtrang.dart';
import 'user.dart';
import 'role.dart';
import 'item.dart';
import 'menu_item_status.dart';

class KitchenMockData {
  static final roleKitchen = Role(
    id: 'r-1',
    code: 'KITCHEN_STAFF',
    name: 'Nhân viên bếp',
    description: 'Nhân viên làm việc tại bếp',
  );

  static final roleWaiter = Role(
    id: 'r-2',
    code: 'WAITER',
    name: 'Nhân viên phục vụ',
    description: 'Nhân viên phục vụ khách',
  );

  static final user1 = User(
    id: 1,
    fullName: 'Nguyễn Văn A',
    email: 'nguyenvana@gmail.com',
    phone: '0901234567',
    passworkHash: '\$2a\$10\$abcdefg',
    fontImage: 'front1.jpg',
    backImage: 'back1.jpg',
    statusId: 1,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
    deletedAt: null,
  );

  static final user2 = User(
    id: 2,
    fullName: 'Trần Thị B',
    email: 'tranthib@gmail.com',
    phone: '0907654321',
    passworkHash: '\$2a\$10\$hijklmn',
    fontImage: 'front2.jpg',
    backImage: 'back2.jpg',
    statusId: 1,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
    deletedAt: null,
  );

  static final menuItemStatusAvailable = MenuItemStatus(
    id: 'mis-1',
    code: 'AVAILABLE',
    name: 'Còn món',
  );

  /// Danh sách các món ăn
  static final items = [
    Item(
      id: 'i-1',
      companyId: 'c-1',
      name: 'Bún bò Huế',
      price: 45000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-2',
      companyId: 'c-1',
      name: 'Phở bò',
      price: 50000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-3',
      companyId: 'c-1',
      name: 'Cơm tấm sườn',
      price: 40000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-4',
      companyId: 'c-1',
      name: 'Bánh mì thịt',
      price: 25000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-5',
      companyId: 'c-1',
      name: 'Bún chả Hà Nội',
      price: 55000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-6',
      companyId: 'c-1',
      name: 'Mì Quảng',
      price: 48000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-7',
      companyId: 'c-1',
      name: 'Cháo lòng',
      price: 35000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-8',
      companyId: 'c-1',
      name: 'Hủ tiếu Nam Vang',
      price: 45000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
  ];

  //****************************************************/
  /// Lấy tất cả các đơn hàng bếp (dữ liệu cứng)
  static List<KitchenOrder> getAllKitchenOrders() {
    final now = DateTime.now();
    return [
      _createOrder(
        id: 'ko-1',
        item: items[0],
        quantity: 2,
        table: 'B-3',
        time: now.subtract(const Duration(minutes: 10)),
        status: KitchenOrderStatus.pending,
        note: 'Ít cay',
      ),
      _createOrder(
        id: 'ko-2',
        item: items[1],
        quantity: 1,
        table: 'B-5',
        time: now.subtract(const Duration(minutes: 8)),
        status: KitchenOrderStatus.pending,
      ),
      _createOrder(
        id: 'ko-3',
        item: items[2],
        quantity: 3,
        table: 'B-7',
        time: now.subtract(const Duration(minutes: 5)),
        status: KitchenOrderStatus.pending,
        note: 'Không rau',
      ),
      _createOrder(
        id: 'ko-4',
        item: items[3],
        quantity: 2,
        table: 'B-2',
        time: now.subtract(const Duration(minutes: 3)),
        status: KitchenOrderStatus.pending,
      ),
      _createOrder(
        id: 'ko-5',
        item: items[4],
        quantity: 1,
        table: 'B-10',
        time: now.subtract(const Duration(minutes: 1)),
        status: KitchenOrderStatus.pending,
        note: 'Nhiều rau',
      ),
    ];
  }

  static KitchenOrder _createOrder({
    required String id,
    required Item item,
    required int quantity,
    required String table,
    required DateTime time,
    required KitchenOrderStatus status,
    String? note,
  }) {
    return KitchenOrder(
      id: id,
      orderId: 'o-${id.split('-').last}',
      orderItemId: 'oi-${id.split('-').last}',
      dishName: item.name,
      quantity: quantity,
      tableNumber: table,
      createdTime:
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      note: note,
      status: status,
      addedBy: user2.id?.toString(),
      createdAt: time,
      itemDetails: item,
      addedByUser: user2,
    );
  }

  static List<KitchenOrder> getOrdersByStatus(KitchenOrderStatus status) {
    return getAllKitchenOrders()
        .where((order) => order.status == status)
        .toList();
  }

  static List<KitchenOrder> getOrdersByTabIndex(int tabIndex) {
    final status = KitchenOrderStatus.fromTabIndex(tabIndex);
    return getOrdersByStatus(status);
  }

  static Map<KitchenOrderStatus, int> getOrderCountByStatus() {
    final allOrders = getAllKitchenOrders();
    return {
      KitchenOrderStatus.pending:
          allOrders.where((o) => o.status == KitchenOrderStatus.pending).length,
      KitchenOrderStatus.completed: 0, // Không có dữ liệu cứng
      KitchenOrderStatus.outOfStock: 0,
      KitchenOrderStatus.cancelled: 0,
    };
  }

  static List<KitchenOrder> searchOrders(String query, {int? tabIndex}) {
    if (query.isEmpty && tabIndex == null) {
      return getAllKitchenOrders();
    }

    var orders =
        tabIndex != null
            ? getOrdersByTabIndex(tabIndex)
            : getAllKitchenOrders();

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      orders =
          orders.where((order) {
            return order.dishName.toLowerCase().contains(lowerQuery) ||
                order.tableNumber.toLowerCase().contains(lowerQuery);
          }).toList();
    }

    return orders;
  }
}
