import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/company_owner.dart';

/// 🌐 Các endpoint base URL
const uri1 = 'https://spring-boot-smartdine.onrender.com/api/companys';
const uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/companys';

/// 🧠 Lớp xử lý gọi API Company + Owner
class CompanyOwnerAPI {
  final String baseUrl;
  const CompanyOwnerAPI({this.baseUrl = uri2});

  /// 🔹 Lấy danh sách công ty và chủ cửa hàng
  Future<List<CompanyOwner>> getCompanyOwners() async {
    final url = Uri.parse('$baseUrl/get-list-company-and-owner');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => CompanyOwner.fromMap(e)).toList();
    } else {
      throw Exception(
        'Lỗi ${response.statusCode}: Không thể tải danh sách công ty và chủ cửa hàng',
      );
    }
  }

  /// 🔹 Xóa công ty
  Future<void> deleteCompany(int companyId) async {
    final url = Uri.parse('$baseUrl/delete/$companyId');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa công ty có ID = $companyId');
    }
  }

  /// 🔹 Lấy chi tiết công ty + chủ cửa hàng
  Future<CompanyOwner?> getCompanyOwnerDetail(int companyId) async {
    final url = Uri.parse('$baseUrl/detail/$companyId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CompanyOwner.fromMap(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Lỗi khi tải chi tiết công ty $companyId');
    }
  }

  /// 🔹 Đổi trạng thái (dạng toggle logic cũ — vẫn có thể dùng nếu backend giữ)
  Future<void> toggleCompanyStatus(int id, bool isActive) async {
    final url = Uri.parse('$baseUrl/toggle/$id/$isActive');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể cập nhật trạng thái công ty');
    }
  }

  /// 🟢 Kích hoạt công ty (statusId = 1)
  Future<void> activateCompany(int id) async {
    final url = Uri.parse('$baseUrl/active/$id');
    print("đang goi den url ${url}");
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    print("đang goi den response ${response}");

    if (response.statusCode != 200) {
      throw Exception('Không thể kích hoạt công ty (ID: $id)');
    }
  }

  /// 🔴 Vô hiệu hóa công ty (statusId = 2)
  Future<void> deactivateCompany(int id) async {
    final url = Uri.parse('$baseUrl/inactive/$id');
    print("đang goi den url ${url}");

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    print("đang goi den response ${response}");

    if (response.statusCode != 200) {
      throw Exception('Không thể vô hiệu hóa công ty (ID: $id)');
    }
  }
}

/// 🧩 Provider chuẩn Riverpod
final companyOwnerApiProvider = Provider<CompanyOwnerAPI>(
  (ref) => const CompanyOwnerAPI(),
);
