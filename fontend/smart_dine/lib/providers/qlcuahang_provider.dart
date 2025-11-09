import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/company_owner_api.dart';
import 'package:mart_dine/models/company_owner.dart';

final qlCuaHangProvider =
    StateNotifierProvider<QlCuaHangNotifier, AsyncValue<List<CompanyOwner>>>(
      (ref) => QlCuaHangNotifier(ref),
    );

class QlCuaHangNotifier extends StateNotifier<AsyncValue<List<CompanyOwner>>> {
  final Ref ref;
  QlCuaHangNotifier(this.ref) : super(const AsyncLoading()) {
    loadCompanyOwners();
  }

  Future<void> loadCompanyOwners() async {
    try {
      final api = ref.read(companyOwnerApiProvider);
      final list = await api.getCompanyOwners();
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteCompany(int companyId) async {
    try {
      final api = ref.read(companyOwnerApiProvider);
      await api.deleteCompany(companyId);
      loadCompanyOwners(); // load lại danh sách sau khi xóa
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
