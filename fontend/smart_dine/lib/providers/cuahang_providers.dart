import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/cuahang_model.dart';
import 'package:mart_dine/models/cuahang_data.dart';

// StateNotifier để quản lý danh sách cửa hàng
class StoreListNotifier extends StateNotifier<List<Store>> {
  StoreListNotifier() : super(StoreMockData.generateMockStores());

  // Thêm cửa hàng mới
  void addStore(Store store) {
    if (!store.isValid) {
      throw Exception('Thông tin cửa hàng không hợp lệ');
    }
    state = [...state, store];
  }

  // Cập nhật cửa hàng
  void updateStore(Store updatedStore) {
    if (!updatedStore.isValid) {
      throw Exception('Thông tin cửa hàng không hợp lệ');
    }
    state = [
      for (final store in state)
        if (store.id == updatedStore.id) updatedStore else store,
    ];
  }

  // Xóa cửa hàng theo ID
  void deleteStore(String storeId) {
    state = state.where((store) => store.id != storeId).toList();
  }

  // Xóa tất cả cửa hàng
  void deleteAllStores() {
    state = [];
  }

  // Kiểm tra có cửa hàng nào không
  bool get isEmpty => state.isEmpty;

  // Lấy số lượng cửa hàng
  int get totalStores => state.length;

  // Lấy cửa hàng theo ID
  Store? getStoreById(String storeId) {
    try {
      return state.firstWhere((store) => store.id == storeId);
    } catch (e) {
      return null;
    }
  }

  // Reset về dữ liệu mock ban đầu
  void resetToMockData() {
    state = StoreMockData.generateMockStores();
  }

  // Load custom mock data
  void loadCustomMockData(int count) {
    state = StoreMockData.generateCustomMockStores(count);
  }
}

// Provider cho danh sách cửa hàng
final storeListProvider = StateNotifierProvider<StoreListNotifier, List<Store>>(
  (ref) {
    return StoreListNotifier();
  },
);

// Provider cho tìm kiếm/lọc cửa hàng
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider cho trạng thái lọc
final statusFilterProvider = StateProvider<StoreStatus?>((ref) => null);

// Provider cho danh sách cửa hàng đã được lọc
final filteredStoresProvider = Provider<List<Store>>((ref) {
  final stores = ref.watch(storeListProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final statusFilter = ref.watch(statusFilterProvider);

  return stores.where((store) {
    // Lọc theo tìm kiếm (tên, chủ, số điện thoại)
    final matchesSearch =
        searchQuery.isEmpty ||
        store.name.toLowerCase().contains(searchQuery) ||
        store.ownerName.toLowerCase().contains(searchQuery) ||
        store.phone.contains(searchQuery) ||
        (store.address?.toLowerCase().contains(searchQuery) ?? false);

    // Lọc theo trạng thái
    final matchesStatus = statusFilter == null || store.status == statusFilter;

    return matchesSearch && matchesStatus;
  }).toList();
});

// Provider để lấy cửa hàng theo ID (dùng cho StoreDetailScreen)
final storeByIdProvider = Provider.family<Store?, String>((ref, storeId) {
  final stores = ref.watch(storeListProvider);
  try {
    return stores.firstWhere((store) => store.id == storeId);
  } catch (e) {
    return null;
  }
});

// Provider cho thống kê
final storeStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final stores = ref.watch(storeListProvider);

  return {
    'total': stores.length,
    'active': stores.where((s) => s.status == StoreStatus.active).length,
    'inactive': stores.where((s) => s.status == StoreStatus.inactive).length,
    'totalBranches': stores.fold<int>(
      0,
      (sum, store) => sum + store.branchNumber,
    ),
    'averageBranches':
        stores.isEmpty
            ? 0.0
            : stores.fold<int>(0, (sum, store) => sum + store.branchNumber) /
                stores.length,
  };
});

// Provider kiểm tra danh sách có rỗng không
final isStoreListEmptyProvider = Provider<bool>((ref) {
  final stores = ref.watch(storeListProvider);
  return stores.isEmpty;
});

// Provider đếm số lượng cửa hàng đã lọc
final filteredStoreCountProvider = Provider<int>((ref) {
  final filteredStores = ref.watch(filteredStoresProvider);
  return filteredStores.length;
});
