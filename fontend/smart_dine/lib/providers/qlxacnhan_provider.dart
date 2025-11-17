import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/company_API.dart';
import 'package:mart_dine/models/pending_company.dart';

/// Quản lý trạng thái danh sách công ty chờ xác nhận
class QlXacNhanNotifier
    extends StateNotifier<AsyncValue<List<PendingCompany>>> {
  final CompanyAPI api;

  QlXacNhanNotifier(this.api) : super(const AsyncLoading()) {
    loadPendingCompanies();
  }

  /// Lấy danh sách công ty chờ xác nhận (statusId = 3)
  Future<void> loadPendingCompanies() async {
    state = const AsyncLoading();
    try {
      final companies = await api.getPendingCompanies();
      state = AsyncData(companies);
    } catch (e, st) {
      state = AsyncError('Không thể tải dữ liệu: $e', st);
    }
  }

  /// Duyệt công ty
  Future<void> approveCompany(int id) async {
    try {
      await api.approveCompany(id);
      await loadPendingCompanies();
    } catch (e, st) {
      state = AsyncError('Lỗi khi duyệt công ty: $e', st);
    }
  }

  /// Từ chối công ty
  Future<void> rejectCompany(int id) async {
    try {
      await api.rejectCompany(id);
      await loadPendingCompanies();
    } catch (e, st) {
      state = AsyncError('Lỗi khi từ chối công ty: $e', st);
    }
  }

  /// Xóa công ty
  Future<void> deleteCompany(int id) async {
    try {
      await api.deleteCompany(id);
      await loadPendingCompanies();
    } catch (e, st) {
      state = AsyncError('Lỗi khi xóa công ty: $e', st);
    }
  }
}

/// Provider chính cho màn quản lý xác nhận công ty
final qlXacNhanProvider =
    StateNotifierProvider<QlXacNhanNotifier, AsyncValue<List<PendingCompany>>>((
      ref,
    ) {
      final api = ref.read(companyApiProvider);
      return QlXacNhanNotifier(api);
    });
