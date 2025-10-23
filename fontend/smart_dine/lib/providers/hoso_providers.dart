import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/hoso_model.dart';
import 'package:mart_dine/models/cuahang_model.dart';
import 'package:mart_dine/providers/cuahang_providers.dart';

// StateNotifier để quản lý chi tiết cửa hàng
class StoreDetailNotifier extends StateNotifier<StoreDetail?> {
  StoreDetailNotifier(this.ref) : super(null);

  final Ref ref;

  // Load store detail by ID từ storeListProvider
  void loadStoreFromList(String storeId) {
    try {
      // Lấy store từ storeListProvider
      final stores = ref.read(storeListProvider);
      final store = stores.firstWhere(
        (s) => s.id == storeId,
        orElse: () => throw Exception('Không tìm thấy cửa hàng'),
      );

      // Convert Store thành StoreDetail
      state = StoreDetail.fromStore(store);
    } catch (e) {
      state = null;
      throw Exception('Không thể tải thông tin cửa hàng: $e');
    }
  }

  // Load store detail by ID (legacy method - giữ lại để tương thích)
  void loadStore(String storeId) {
    loadStoreFromList(storeId);
  }

  // Toggle activation status
  void toggleActivation() {
    if (state != null) {
      state = state!.copyWith(isActive: !state!.isActive);

      // Đồng bộ trạng thái về Store model
      _syncToStoreList();
    }
  }

  // Sync trạng thái về storeListProvider
  void _syncToStoreList() {
    if (state != null) {
      final stores = ref.read(storeListProvider);
      final storeIndex = stores.indexWhere((s) => s.id == state!.id);

      if (storeIndex != -1) {
        final updatedStore = stores[storeIndex].copyWith(
          status: state!.isActive ? StoreStatus.active : StoreStatus.inactive,
        );
        ref.read(storeListProvider.notifier).updateStore(updatedStore);
      }
    }
  }

  // Update store detail
  void updateStoreDetail(StoreDetail updatedStore) {
    if (!updatedStore.isValid) {
      throw Exception('Thông tin cửa hàng không hợp lệ');
    }
    state = updatedStore;
    _syncToStoreList();
  }

  // Update specific fields
  void updateName(String name) {
    if (state != null) {
      state = state!.copyWith(name: name);
      _syncToStoreList();
    }
  }

  void updateEmail(String email) {
    if (state != null) {
      state = state!.copyWith(email: email);
    }
  }

  void updatePhone(String phone) {
    if (state != null) {
      state = state!.copyWith(phone: phone);
      _syncToStoreList();
    }
  }

  void updateTotalBranches(int branches) {
    if (state != null) {
      state = state!.copyWith(totalBranches: branches);
      _syncToStoreList();
    }
  }

  void updateTotalEmployees(int employees) {
    if (state != null) {
      state = state!.copyWith(totalEmployees: employees);
    }
  }

  void updateServicePackage(String package) {
    if (state != null) {
      state = state!.copyWith(servicePackage: package);
    }
  }

  // Activate store
  void activateStore() {
    if (state != null && !state!.isActive) {
      state = state!.copyWith(isActive: true);
      _syncToStoreList();
    }
  }

  // Deactivate store
  void deactivateStore() {
    if (state != null && state!.isActive) {
      state = state!.copyWith(isActive: false);
      _syncToStoreList();
    }
  }

  // Clear state
  void clearStore() {
    state = null;
  }

  // Reload current store
  void reloadStore() {
    if (state != null) {
      loadStore(state!.id);
    }
  }
}

// Provider cho store detail (với Ref để access storeListProvider)
final storeDetailProvider =
    StateNotifierProvider<StoreDetailNotifier, StoreDetail?>((ref) {
      return StoreDetailNotifier(ref);
    });

// Provider kiểm tra store đã được load chưa
final isStoreLoadedProvider = Provider<bool>((ref) {
  final store = ref.watch(storeDetailProvider);
  return store != null;
});

// Provider kiểm tra store có active không
final isStoreActiveProvider = Provider<bool>((ref) {
  final store = ref.watch(storeDetailProvider);
  return store?.isActive ?? false;
});

// Provider lấy thông tin cơ bản
final storeBasicInfoProvider = Provider<Map<String, String>>((ref) {
  final store = ref.watch(storeDetailProvider);
  if (store == null) return {};

  return {
    'name': store.name,
    'email': store.email,
    'phone': store.phone,
    'code': store.code,
    'establishDate': store.formattedEstablishDate,
  };
});

// Provider lấy thông tin hệ thống
final storeSystemInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final store = ref.watch(storeDetailProvider);
  if (store == null) return {};

  return {
    'totalBranches': store.totalBranches,
    'totalEmployees': store.totalEmployees,
    'servicePackage': store.servicePackage,
    'isActive': store.isActive,
    'statusDisplay': store.statusDisplay,
  };
});

// Provider validation
final isStoreDetailValidProvider = Provider<bool>((ref) {
  final store = ref.watch(storeDetailProvider);
  return store?.isValid ?? false;
});

// Provider cho license images
final storeLicenseImagesProvider = Provider<List<String>>((ref) {
  final store = ref.watch(storeDetailProvider);
  return store?.licenseImages ?? [];
});
