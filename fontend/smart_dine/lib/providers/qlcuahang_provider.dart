import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/api/company_API.dart'; // hoặc store_API.dart tùy bạn
import 'package:mart_dine/models/company.dart';

class QlCuaHangNotifier extends StateNotifier<AsyncValue<List<Company>>> {
  final CompanyAPI _api;

  QlCuaHangNotifier(this._api) : super(const AsyncValue.loading()) {
    loadActiveStores();
  }

  // Lấy danh sách cửa hàng đã duyệt (statusId = 1)
  Future<void> loadActiveStores() async {
    try {
      final stores = await _api.getActiveCompanies(); // dùng API ở trên
      state = AsyncValue.data(stores);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Bật/tắt cửa hàng (active / inactive)
  Future<void> toggleStoreStatus(int id, bool isActive) async {
    try {
      await _api.toggleCompanyStatus(id, isActive);
      await loadActiveStores();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provider chính
final qlCuaHangProvider =
    StateNotifierProvider<QlCuaHangNotifier, AsyncValue<List<Company>>>(
      (ref) => QlCuaHangNotifier(ref.watch(companyApiProvider)),
    );
