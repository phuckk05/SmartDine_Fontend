// file: providers/company_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API_owner/company_API.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/models_owner/company.dart';

// Provider này cung cấp thông tin (giả lập) của công ty
final companyProvider = FutureProvider<Company?>((ref) async {
  // SỬA: Lấy companyId từ ownerProfileProvider để đảm bảo tính chính xác và đồng bộ.
  // Provider sẽ chờ ownerProfileProvider tải xong rồi mới thực thi.
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;

  // Nếu không có companyId (ví dụ: người dùng chưa đăng nhập hoặc dữ liệu session lỗi),
  // trả về null để không gọi API.
  if (companyId == null) {
    return null;
  }

  // Khi có companyId, gọi API để lấy thông tin công ty.
  // SỬA: Sử dụng đúng provider API (không phải StateProvider)
  final api = ref.read(companyApiProvider);
  return api.fetchCompanyById(companyId);
});

// Provider giả lập cho thông tin chủ sở hữu (Vì nó không có trong model Company)
// SỬA: Dùng dữ liệu thật từ ownerProfileProvider
final ownerInfoProvider = Provider<Map<String, String>>((ref) {
  // Watch ownerProfileProvider để lấy dữ liệu thật
  final ownerAsync = ref.watch(ownerProfileProvider);

  // Trả về dữ liệu khi có, hoặc giá trị mặc định khi đang tải/lỗi
  return ownerAsync.when(
    data: (owner) => {"email": owner.email, "phone": owner.phone},
    loading: () => {"email": "Đang tải...", "phone": "Đang tải..."},
    error: (e, s) => {"email": "Lỗi", "phone": "Lỗi"},
  );
});