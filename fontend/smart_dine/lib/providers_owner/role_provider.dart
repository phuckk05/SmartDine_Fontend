// file: providers/role_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/role.dart';
import 'package:mart_dine/API_owner/role_API.dart';
// <<< SỬA: Thành FutureProvider >>>
final roleListProvider = FutureProvider<List<Role>>((ref) async {
  final apiService = ref.watch(roleApiProvider);
  return apiService.fetchRoles(); // Gọi API
});

// Hàm getStatusName và formatters giữ nguyên
String getStatusName(int statusId) {
  // Model User Java có statusId, 1=Active (Giả định)
  return statusId == 1 ? "Bình thường" : "Đã khóa";
}
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return "$day-$month-$year";
}
String formatCurrency(double amount) {
  String S = amount.toStringAsFixed(0);
  String formatted = S.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  return "$formatted đ";
}