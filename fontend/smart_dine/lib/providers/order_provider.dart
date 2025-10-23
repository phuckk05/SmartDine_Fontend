import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // Cần cho createOrderFromTable

// ✅ BƯỚC 1: IMPORT CÁC MODEL CẦN THIẾT
// (Hãy đảm bảo đường dẫn 'mart_dine/models/...' là chính xác)
import 'package:mart_dine/models/order.dart'; // Import OrderModel
import 'package:mart_dine/models/dish.dart'; // Import DishModel
import 'package:mart_dine/models/table.dart'; // Import TableModel
import 'package:mart_dine/models/menu.dart'; // Import MenuItemModel (để chuyển đổi)


class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super([]) {
    _loadInitialData(); // Tải dữ liệu mẫu khi notifier được khởi tạo
  }
  
  // ✅ BƯỚC 2: HÀM "CẦU NỐI" TỪ TABLE_PROVIDER
  /// Nhận dữ liệu từ TableModel (Nhân viên) và tạo ra một OrderModel (Thu ngân)
  /// Hàm này được gọi bởi 'table_provider.dart'
  /// Nó trả về ID của đơn hàng mới được tạo
  String createOrderFromTable(TableModel table) {
    
    // 1. Chuyển đổi List<MenuItemModel> thành List<DishModel>
    final List<DishModel> dishes = table.existingItems.map((menuItem) {
      return DishModel(
        id: menuItem.id, // Dùng chung ID
        name: menuItem.name,
        price: menuItem.price,
        note: null, // MenuItemModel không có 'note'
      );
    }).toList();

    // 2. Tạo OrderModel mới
    final newOrder = OrderModel(
      // id: Sẽ được tự tạo bởi constructor của OrderModel
      tableName: table.name,
      tableId: table.id, // Lấy tableId từ TableModel
      customerCount: table.customerCount ?? 0,
      items: dishes, // Dùng danh sách DishModel đã chuyển đổi
      totalAmount: table.totalAmount,
      orderTime: DateTime.now(),
      status: OrderStatus.confirmed, // ✅ Đặt là 'confirmed' để Thu ngân thấy
    );

    // 3. Thêm đơn hàng mới vào danh sách
    state = [...state, newOrder];
    debugPrint("Đã tạo đơn hàng mới từ Bàn ${table.name} cho Thu ngân.");

    // 4. Trả về ID
    return newOrder.id;
  }


  // Thêm một đơn hàng mới, với trạng thái mặc định là 'newOrder'
  void addOrder({
    required String tableName,
    required String tableId,
    required int customerCount,
    required List<DishModel> items,
    required double totalAmount,
    DateTime? orderTime,
    OrderPaymentMethod? paymentMethod,
    OrderStatus status = OrderStatus.newOrder, // ✅ Trạng thái mặc định
  }) {
    final newOrder = OrderModel(
      tableName: tableName,
      tableId: tableId,
      customerCount: customerCount,
      items: items,
      totalAmount: totalAmount,
      orderTime: orderTime ?? DateTime.now(),
      paymentMethod: paymentMethod,
      status: status, // ✅ Sử dụng trạng thái được cung cấp
    );
    state = [...state, newOrder];
  }

  // Cập nhật một đơn hàng đã tồn tại
  void updateOrder(String orderId, {
    String? tableName,
    String? tableId,
    int? customerCount,
    List<DishModel>? items,
    double? totalAmount,
    DateTime? orderTime,
    ValueGetter<OrderPaymentMethod?>? paymentMethod,
    OrderStatus? status, // ✅ Cho phép cập nhật trạng thái
  }) {
    state = state.map((order) {
      if (order.id == orderId) {
        // Tính toán lại tổng tiền nếu danh sách món ăn được cập nhật
        final finalTotalAmount = items != null
            ? items.fold(0.0, (sum, item) => sum + item.price)
            : totalAmount ?? order.totalAmount;

        return order.copyWith(
          tableName: tableName,
          tableId: tableId,
          customerCount: customerCount,
          items: items,
          totalAmount: finalTotalAmount, // Sử dụng tổng tiền đã tính lại
          orderTime: orderTime,
          paymentMethod: paymentMethod,
          status: status, // ✅ Cập nhật trạng thái
        );
      }
      return order;
    }).toList();
  }

  // ✅ MỚI: Phương thức để nhân viên xác nhận đơn hàng
  void confirmOrder(String orderId) {
    updateOrder(orderId, status: OrderStatus.confirmed);
    debugPrint("Đơn hàng đã được xác nhận: $orderId"); // Để debug
  }

  // Đánh dấu một đơn hàng đã được thanh toán (Hành động của Thu ngân)
  void markOrderAsPaid(String orderId, OrderPaymentMethod method) {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(
            paymentMethod: () => method, status: OrderStatus.paid); // ✅ Cập nhật trạng thái thành 'paid'
      }
      return order;
    }).toList();
  }

  // Xóa một đơn hàng
  void removeOrder(String orderId) {
    state = state.where((order) => order.id != orderId).toList();
  }

  // Lấy một đơn hàng theo ID
  OrderModel? getOrderById(String orderId) {
    try {
      return state.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Tải dữ liệu mẫu ban đầu
  void _loadInitialData() {
    if (state.isNotEmpty) return;

    final dummyDishes1 = [
      DishModel(name: 'Bánh mỳ trứng ốp la', price: 20000, note: 'ít cay'),
      DishModel(name: 'Phở bò tái lăn', price: 50000),
      DishModel(name: 'Trà đá', price: 10000),
    ];
    final dummyDishes2 = [
      DishModel(name: 'Cơm rang thập cẩm', price: 65000),
      DishModel(name: 'Súp gà', price: 30000),
      DishModel(name: 'Coca Cola', price: 15000),
    ];
    final dummyDishes3 = [
      DishModel(name: 'Mì Ý sốt bò băm', price: 80000),
      DishModel(name: 'Salad Caesar', price: 55000),
      DishModel(name: 'Nước cam ép', price: 35000),
      DishModel(name: 'Bánh Tiramisu', price: 60000),
    ];

    // Đơn hàng mới tạo (Chưa xác nhận - KHÔNG hiển thị trên thông báo của Thu ngân)
    addOrder(
      tableName: 'Bàn A-1',
      tableId: 'table_A1',
      customerCount: 2,
      items: dummyDishes2,
      totalAmount: dummyDishes2.fold(0.0, (sum, item) => sum + item.price),
      orderTime: DateTime.now().subtract(const Duration(minutes: 5)),
      status: OrderStatus.newOrder, // Trạng thái là đơn hàng mới
    );

    // Đơn hàng đã được nhân viên xác nhận (SẼ hiển thị trên thông báo của Thu ngân)
    addOrder(
      tableName: 'Bàn A-2',
      tableId: 'table_A2',
      customerCount: 3,
      items: dummyDishes1,
      totalAmount: dummyDishes1.fold(0.0, (sum, item) => sum + item.price),
      orderTime: DateTime.now().subtract(const Duration(minutes: 10)),
      status: OrderStatus.confirmed, // ✅ Trạng thái đã xác nhận
    );

    // Một đơn hàng đã xác nhận khác
     addOrder(
      tableName: 'Bàn B-5',
      tableId: 'table_B5',
      customerCount: 4,
      items: dummyDishes3,
      totalAmount: dummyDishes3.fold(0.0, (sum, item) => sum + item.price),
      orderTime: DateTime.now().subtract(const Duration(minutes: 2)),
      status: OrderStatus.confirmed, // ✅ Trạng thái đã xác nhận
    );

    // Đơn hàng đã thanh toán (KHÔNG hiển thị trên thông báo của Thu ngân)
    addOrder(
      tableName: 'Bàn C-1',
      tableId: 'table_C1',
      customerCount: 4,
      items: [DishModel(name: 'Cafe Đen', price: 20000)],
      totalAmount: 20000,
      orderTime: DateTime.now().subtract(const Duration(hours: 2)),
      paymentMethod: OrderPaymentMethod.cash,
      status: OrderStatus.paid, // ✅ Trạng thái đã thanh toán
    );
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>(
  (ref) => OrderNotifier(),
);