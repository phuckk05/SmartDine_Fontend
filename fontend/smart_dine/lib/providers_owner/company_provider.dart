// file: providers/company_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API_owner/company_API.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/models_owner/company.dart'; // Đảm bảo đường dẫn đúng

// Provider này cung cấp thông tin (giả lập) của công ty
final companyProvider = FutureProvider<Company?>((ref) async {
  final apiService = ref.read(companyApiProvider);

  // 1. Lấy thông tin owner để có companyId.
  // .future sẽ đảm bảo chúng ta đợi cho đến khi có dữ liệu owner.
  final owner = await ref.watch(ownerProfileProvider.future);
  final companyId = owner.companyId;

  // 2. Nếu không có companyId, không cần làm gì thêm.
  if (companyId == null) {
    return null;
  }

  // 3. Gọi API để lấy thông tin công ty bằng ID.
  return apiService.fetchCompanyById(companyId);
});

// Provider giả lập cho thông tin chủ sở hữu (Vì nó không có trong model Company)
// Dữ liệu này khớp với UI screen_profile.dart
final ownerInfoProvider = Provider<Map<String, String>>((ref) {
  return {
    "email": "phuck3242@gmail.com",
    "phone": "32435345345",
  };
});