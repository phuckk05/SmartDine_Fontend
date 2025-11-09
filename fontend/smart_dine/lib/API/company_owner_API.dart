import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/company_owner.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/companys';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/companys';

class CompanyOwnerAPI {
  /// 🧩 Lấy danh sách công ty đã duyệt (statusId = 1) và chủ cửa hàng
  Future<List<CompanyOwner>> getCompanyOwners() async {
    final response = await http.get(
      Uri.parse('$uri2/get-list-company-and-owner'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CompanyOwner.fromMap(e)).toList();
    } else {
      throw Exception(
        'Lỗi ${response.statusCode} khi tải danh sách công ty và chủ cửa hàng',
      );
    }
  }

  /// 🧩 Xóa công ty (bao gồm cả chủ công ty)
  Future<void> deleteCompany(int companyId) async {
    final response = await http.delete(
      Uri.parse('$uri2/delete/$companyId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa công ty có id = $companyId');
    }
  }

  /// 🧩 Lấy chi tiết thông tin công ty + chủ cửa hàng
  // Future<CompanyOwner?> getCompanyOwnerDetail(int companyId) async {
  //   final response = await http.get(
  //     Uri.parse('$uri2/detail/$companyId'),
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = jsonDecode(response.body);
  //     return CompanyOwner.fromMap(data);
  //   } else if (response.statusCode == 404) {
  //     return null; // không tìm thấy
  //   } else {
  //     throw Exception('Lỗi khi tải chi tiết công ty $companyId');
  //   }
  // }

  // /// 🧩 Đổi trạng thái hoạt động công ty
  // Future<void> toggleCompanyStatus(int id, bool isActive) async {
  //   final response = await http.put(
  //     Uri.parse('$uri2/toggle/$id/$isActive'),
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Không thể cập nhật trạng thái công ty');
  //   }
  // }
}

/// Provider để dùng trong Riverpod
final companyOwnerApiProvider = StateProvider<CompanyOwnerAPI>(
  (ref) => CompanyOwnerAPI(),
);
