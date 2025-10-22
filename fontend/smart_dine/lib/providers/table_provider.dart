import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/completed_order.dart';
import 'package:mart_dine/models/menu.dart';
import 'package:mart_dine/models/table.dart';
import 'package:uuid/uuid.dart';

//________________________________________________________________________________
//
//         🔹 STATE AND NOTIFIER 🔹
//________________________________________________________________________________

/// Đại diện cho trạng thái của các bàn và các đơn hàng đã hoàn thành.
class TableState {
  final List<TableModel> tables;
  final TableModel? selectedTable; // Bàn đang được chọn/thao tác
  final String searchQuery; // Chuỗi tìm kiếm hiện tại
  final TableStatus? filterStatus; // Trạng thái lọc hiện tại
  final TableZone filterZone; // Khu vực lọc hiện tại
  final List<CompletedOrderModel> completedOrders; // Danh sách các đơn hàng đã thanh toán

  TableState({
    required this.tables,
    this.selectedTable,
    this.searchQuery = '',
    this.filterStatus,
    this.filterZone = TableZone.all,
    List<CompletedOrderModel>? completedOrders, // Khởi tạo nếu không có
  }) : completedOrders = completedOrders ?? _initialCompletedOrders;

  /// Phương thức giúp tạo một bản sao của TableState với các thuộc tính được cập nhật.
  TableState copyWith({
    List<TableModel>? tables,
    TableModel? selectedTable,
    String? searchQuery,
    TableStatus? filterStatus,
    TableZone? filterZone,
    List<CompletedOrderModel>? completedOrders,
  }) {
    return TableState(
      tables: tables ?? this.tables,
      selectedTable: selectedTable ?? this.selectedTable,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      filterZone: filterZone ?? this.filterZone,
      completedOrders: completedOrders ?? this.completedOrders,
    );
  }
}

/// [TableNotifier] là một StateNotifier quản lý TableState.
/// Nó chứa các logic nghiệp vụ để thao tác với danh sách bàn ăn.
class TableNotifier extends StateNotifier<TableState> {
  TableNotifier() : super(TableState(tables: _initialTables));

  final Uuid _uuid = const Uuid(); // Dùng để tạo ID duy nhất

  /// Trả về danh sách bàn đã được lọc và tìm kiếm dựa trên trạng thái hiện tại.
  List<TableModel> get filteredTables {
    List<TableModel> currentTables = state.tables;

    // Lọc theo trạng thái
    if (state.filterStatus != null) {
      currentTables = currentTables
          .where((table) => table.status == state.filterStatus)
          .toList();
    }
    // Lọc theo khu vực
    if (state.filterZone != TableZone.all) {
      currentTables = currentTables
          .where((table) => table.zone == state.filterZone)
          .toList();
    }
    // Tìm kiếm theo tên bàn
    if (state.searchQuery.isNotEmpty) {
      currentTables = currentTables
          .where((table) =>
              table.name.toLowerCase().contains(state.searchQuery.toLowerCase()))
          .toList();
    }
    return currentTables;
  }

  /// Cập nhật chuỗi tìm kiếm.
  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);

  /// Cập nhật trạng thái lọc.
  void setFilterStatus(TableStatus? status) =>
      state = state.copyWith(filterStatus: status);

  /// Cập nhật khu vực lọc.
  void setFilterZone(TableZone zone) => state = state.copyWith(filterZone: zone);

  /// Đặt bàn được chọn hiện tại.
  void selectTable(TableModel table) =>
      state = state.copyWith(selectedTable: table);

  /// Cập nhật số lượng khách và trạng thái của một bàn.
  void setCustomerCount(String tableId, int count) {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.copyWith(
          customerCount: count,
          status: TableStatus.reserved, // Ban đầu là reserved khi nhập số khách
        );
      }
      return table;
    }).toList();
    state = state.copyWith(tables: updatedTables);
  }

  /// Cập nhật danh sách món ăn và tổng tiền cho một bàn, đồng thời chuyển trạng thái sang "serving".
  /// Nếu khách gọi thêm món, hủy cờ "chờ thanh toán".
  void updateTableOrder(String tableId, List<MenuItemModel> newItems) {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        final updatedItems = [...table.existingItems, ...newItems];
        final newTotalAmount =
            updatedItems.fold(0.0, (sum, item) => sum + item.price);
        return table.copyWith(
          existingItems: updatedItems,
          totalAmount: newTotalAmount,
          status: TableStatus.serving,
          isPendingPayment: false, // ✅ Nếu khách gọi thêm món, hủy yêu cầu TT
        );
      }
      return table;
    }).toList();
    state = state.copyWith(tables: updatedTables);
  }

  /// ✅ HÀM MỚI: Dành cho nút "Yêu cầu TT" bên màn hình Menu
  /// Cập nhật món ăn VÀ yêu cầu thanh toán ngay lập tức.
  void updateOrderAndRequestCheckout(String tableId, List<MenuItemModel> newItems) {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        // 1. Logic thêm món (từ hàm updateTableOrder)
        final updatedItems = [...table.existingItems, ...newItems];
        final newTotalAmount =
            updatedItems.fold(0.0, (sum, item) => sum + item.price);
        
        return table.copyWith(
          existingItems: updatedItems,
          totalAmount: newTotalAmount,
          status: TableStatus.serving, // Đảm bảo vẫn là 'serving'
          
          // 2. Logic yêu cầu TT (từ hàm requestCheckout)
          isPendingPayment: true, // ✅ Set cờ chờ thanh toán ngay
        );
      }
      return table;
    }).toList();
    state = state.copyWith(tables: updatedTables);
  }


  // ✅ HÀM Dành cho Nhân viên (từ màn hình Chi tiết bàn)
  /// Nhân viên yêu cầu thanh toán, set cờ isPendingPayment = true.
  void requestCheckout(String tableId) {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId && table.status == TableStatus.serving) {
        return table.copyWith(
          isPendingPayment: true, // Đánh dấu chờ thanh toán
        );
      }
      return table;
    }).toList();
    state = state.copyWith(tables: updatedTables);
  }

  // ✅ HÀM NÀY DÀNH CHO THU NGÂN:
  /// Xử lý quá trình thanh toán cho một bàn.
  /// Chuyển bàn về trạng thái "available", reset thông tin khách và món ăn.
  /// Thêm đơn hàng vào danh sách `completedOrders`.
  void checkout(String tableId) {
    TableModel? tableToCheckout;
    try {
      // Tìm bàn cần thanh toán.
      tableToCheckout = state.tables.firstWhere((t) => t.id == tableId);
    } catch (e) {
      // In lỗi ra console và thoát nếu không tìm thấy bàn.
      print('Error: Could not find table with ID $tableId for checkout: $e');
      return;
    }

    // Nếu tìm thấy bàn (tableToCheckout không null), tiếp tục xử lý
    final newCompletedOrder = CompletedOrderModel(
      id: _uuid.v4(), // Tạo ID duy nhất cho đơn hàng hoàn thành
      tableName: tableToCheckout.name,
      customerCount: tableToCheckout.customerCount ?? 0,
      items: List.from(tableToCheckout.existingItems), // Sao chép danh sách món
      totalAmount: tableToCheckout.totalAmount,
      checkoutTime: DateTime.now(),
    );

    // Thêm đơn hàng mới vào danh sách các đơn hàng đã hoàn thành
    final updatedCompletedOrders = [...state.completedOrders, newCompletedOrder];

    // Cập nhật trạng thái của bàn sau khi thanh toán
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.copyWith(
          status: TableStatus.available, // Chuyển về trạng thái trống
          customerCount: 0, // Reset số khách
          totalAmount: 0.0, // Reset tổng tiền
          existingItems: [], // Xóa danh sách món đã đặt
          isPendingPayment: false, // ✅ Reset cờ khi thanh toán xong
        );
      }
      return table;
    }).toList();

    // Cập nhật trạng thái của notifier
    state = state.copyWith(
      tables: updatedTables,
      completedOrders: updatedCompletedOrders,
    );
  }
}

//________________________________________________________________________________
//
//         🔹 PROVIDERS AND SAMPLE DATA 🔹
//________________________________________________________________________________

/// [tableProvider] cung cấp quyền truy cập vào [TableNotifier] và [TableState] của nó.
final tableProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  return TableNotifier();
});

/// [filteredTablesProvider] cung cấp danh sách bàn đã được lọc và tìm kiếm.
/// Nó lắng nghe thay đổi từ [tableProvider] và gọi getter `filteredTables`.
final filteredTablesProvider = Provider<List<TableModel>>((ref) {
  // watch tableProvider để provider này được cập nhật khi TableState thay đổi
  ref.watch(tableProvider);
  return ref.read(tableProvider.notifier).filteredTables;
});

/// [completedOrdersProvider] cung cấp danh sách các đơn hàng đã hoàn thành.
/// Nó lắng nghe thay đổi từ thuộc tính `completedOrders` của [TableState].
final completedOrdersProvider = Provider<List<CompletedOrderModel>>((ref) {
  return ref.watch(tableProvider).completedOrders;
});

//________________________________________________________________________________
//
//         🔹 INITIAL DATA (Dữ liệu mẫu) 🔹
//________________________________________________________________________________

// Dữ liệu mẫu cho các món ăn trong menu
final _menuItemsData = {
  'pho_bo': MenuItemModel(
      id: 'M1',
      name: 'Phở bò',
      price: 50000,
      category: MenuCategory.mainCourse),
  'bun_cha': MenuItemModel(
      id: 'M2',
      name: 'Bún chả',
      price: 45000,
      category: MenuCategory.mainCourse),
  'mi_quang': MenuItemModel(
      id: 'M3',
      name: 'Mì Quảng',
      price: 40000,
      category: MenuCategory.mainCourse),
  'com_tam': MenuItemModel(
      id: 'M4',
      name: 'Cơm tấm sườn bì',
      price: 55000,
      category: MenuCategory.mainCourse),
  'hu_tieu': MenuItemModel(
      id: 'M5',
      name: 'Hủ tiếu Nam Vang',
      price: 50000,
      category: MenuCategory.mainCourse),
  'banh_xeo': MenuItemModel(
      id: 'M6',
      name: 'Bánh xèo',
      price: 35000,
      category: MenuCategory.mainCourse),
  'lau_thai': MenuItemModel(
      id: 'M7',
      name: 'Lẩu Thái hải sản',
      price: 250000,
      category: MenuCategory.mainCourse),
  'goi_cuon': MenuItemModel(
      id: 'M8',
      name: 'Gỏi cuốn',
      price: 30000,
      category: MenuCategory.mainCourse),
  'ca_phe_sua': MenuItemModel(
      id: 'D1',
      name: 'Cà phê sữa',
      price: 25000,
      category: MenuCategory.drink),
  'tra_dao': MenuItemModel(
      id: 'D2',
      name: 'Trà đào cam sả',
      price: 35000,
      category: MenuCategory.drink),
  'nuoc_cam': MenuItemModel(
      id: 'D3',
      name: 'Nước cam ép',
      price: 30000,
      category: MenuCategory.drink),
  'coca_cola': MenuItemModel(
      id: 'D4',
      name: 'Coca-Cola',
      price: 15000,
      category: MenuCategory.drink),
};

// Dữ liệu mẫu cho các đơn hàng đã hoàn thành
final List<CompletedOrderModel> _initialCompletedOrders = [
  CompletedOrderModel(
    id: 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
    tableName: 'A-2',
    customerCount: 4,
    items: [
      _menuItemsData['pho_bo']!,
      _menuItemsData['pho_bo']!,
      _menuItemsData['tra_dao']!,
      _menuItemsData['coca_cola']!,
    ],
    totalAmount: 150000,
    checkoutTime: DateTime(2025, 9, 23, 10, 42),
  ),
  CompletedOrderModel(
    id: 'b2c3d4e5-f6a7-8901-2345-67890abcdef1',
    tableName: 'C-1',
    customerCount: 2,
    items: [
      _menuItemsData['bun_cha']!,
      _menuItemsData['ca_phe_sua']!,
    ],
    totalAmount: 70000,
    checkoutTime: DateTime.now().subtract(const Duration(days: 1)),
  ),
  CompletedOrderModel(
    id: 'c3d4e5f6-a7b8-9012-3456-7890abcdef12',
    tableName: 'B-2',
    customerCount: 6,
    items: [
      _menuItemsData['lau_thai']!,
      _menuItemsData['coca_cola']!,
      _menuItemsData['coca_cola']!,
      _menuItemsData['coca_cola']!,
    ],
    totalAmount: 295000,
    checkoutTime: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];

// Dữ liệu mẫu cho các bàn ăn ban đầu
// (Trường isPendingPayment sẽ tự động là false do giá trị mặc định trong constructor)
final List<TableModel> _initialTables = [
  // Khu A - Trong nhà
  TableModel(
      id: 'T1',
      name: 'A-1',
      seats: 4,
      status: TableStatus.available,
      zone: TableZone.indoor),
  TableModel(
      id: 'T2',
      name: 'A-2',
      seats: 6,
      status: TableStatus.serving,
      zone: TableZone.indoor,
      customerCount: 4,
      existingItems: [_menuItemsData['pho_bo']!, _menuItemsData['tra_dao']!],
      totalAmount: 85000),
  TableModel(
      id: 'T3',
      name: 'A-3',
      seats: 8,
      status: TableStatus.available,
      zone: TableZone.indoor),
  TableModel(
      id: 'T4',
      name: 'A-4',
      seats: 4,
      status: TableStatus.reserved,
      zone: TableZone.indoor,
      customerCount: 2),

  // Khu B - VIP
  TableModel(
      id: 'T5',
      name: 'B-1',
      seats: 4,
      status: TableStatus.available,
      zone: TableZone.vip),
  TableModel(
      id: 'T6',
      name: 'B-2',
      seats: 6,
      status: TableStatus.serving,
      zone: TableZone.vip,
      customerCount: 6,
      existingItems: [
        _menuItemsData['lau_thai']!,
        _menuItemsData['coca_cola']!,
        _menuItemsData['coca_cola']!
      ],
      totalAmount: 280000,
      isPendingPayment: true), // ✅ Thêm 1 bàn đang chờ TT để test
  TableModel(
      id: 'T7',
      name: 'B-3',
      seats: 8,
      status: TableStatus.reserved,
      zone: TableZone.vip,
      customerCount: 8),

  // Khu C - Ngoài trời
  TableModel(
      id: 'T8',
      name: 'C-1',
      seats: 4,
      status: TableStatus.serving,
      zone: TableZone.outdoor,
      customerCount: 3,
      existingItems: [
        _menuItemsData['bun_cha']!,
        _menuItemsData['ca_phe_sua']!
      ],
      totalAmount: 70000),
  TableModel(
      id: 'T9',
      name: 'C-2',
      seats: 6,
      status: TableStatus.available,
      zone: TableZone.outdoor),
  TableModel(
      id: 'T10',
      name: 'C-3',
      seats: 4,
      status: TableStatus.reserved,
      zone: TableZone.outdoor,
      customerCount: 4),
  TableModel(
      id: 'T11',
      name: 'C-4',
      seats: 8,
      status: TableStatus.available,
      zone: TableZone.outdoor),

  // Khu D - Yên tĩnh
  TableModel(
      id: 'T12',
      name: 'D-1',
      seats: 2,
      status: TableStatus.available,
      zone: TableZone.quiet),
  TableModel(
      id: 'T13',
      name: 'D-2',
      seats: 2,
      status: TableStatus.serving,
      zone: TableZone.quiet,
      customerCount: 2,
      existingItems: [_menuItemsData['mi_quang']!],
      totalAmount: 40000),
  TableModel(
      id: 'T14',
      name: 'D-3',
      seats: 4,
      status: TableStatus.available,
      zone: TableZone.quiet),

  // Dữ liệu bổ sung
  TableModel(
      id: 'T15',
      name: 'A-5',
      seats: 6,
      status: TableStatus.available,
      zone: TableZone.indoor),
  TableModel(
      id: 'T16',
      name: 'A-6',
      seats: 4,
      status: TableStatus.serving,
      zone: TableZone.indoor,
      customerCount: 4,
      existingItems: [
        _menuItemsData['com_tam']!,
        _menuItemsData['hu_tieu']!,
        _menuItemsData['nuoc_cam']!
      ],
      totalAmount: 135000),
  TableModel(
      id: 'T17',
      name: 'B-4',
      seats: 6,
      status: TableStatus.reserved,
      zone: TableZone.vip,
      customerCount: 5),
  TableModel(
      id: 'T18',
      name: 'C-5',
      seats: 8,
      status: TableStatus.available,
      zone: TableZone.outdoor),
  TableModel(
      id: 'T19',
      name: 'D-4',
      seats: 2,
      status: TableStatus.serving,
      zone: TableZone.quiet,
      customerCount: 1,
      existingItems: [_menuItemsData['ca_phe_sua']!],
      totalAmount: 25000),
  TableModel(
      id: 'T20',
      name: 'A-7',
      seats: 8,
      status: TableStatus.reserved,
      zone: TableZone.indoor,
      customerCount: 7),
  TableModel(
      id: 'T21',
      name: 'C-6',
      seats: 4,
      status: TableStatus.available,
      zone: TableZone.outdoor),
  TableModel(
      id: 'T22',
      name: 'B-5',
      seats: 8,
      status: TableStatus.serving,
      zone: TableZone.vip,
      customerCount: 5,
      existingItems: [
        _menuItemsData['goi_cuon']!,
        _menuItemsData['banh_xeo']!,
        _menuItemsData['tra_dao']!
      ],
      totalAmount: 100000),
  TableModel(
      id: 'T23',
      name: 'A-8',
      seats: 4,
      status: TableStatus.available,
      zone: TableZone.indoor),
  TableModel(
      id: 'T24',
      name: 'C-7',
      seats: 2,
      status: TableStatus.reserved,
      zone: TableZone.outdoor,
      customerCount: 2),
];