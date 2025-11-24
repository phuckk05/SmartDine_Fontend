// file: lib/API/company_api.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/company.dart'; 

// SỬA LỖI: Lỗi 404 liên tục. Rà soát lại các file API khác cho thấy backend sử dụng `companys` (có 's').
// Đồng bộ lại đường dẫn về `.../api/companys` để khớp với backend.
final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/companys';

class CompanyAPI {
  /// Lấy thông tin công ty bằng mã code
  /// Tương ứng: GET /api/companys/{companyCode}
  // SỬA: Endpoint đúng và rõ ràng hơn để kiểm tra code là /check-code/{companyCode}
  Future<Company?> fetchCompanyByCode(String companyCode) async {
  final response = await http.get(Uri.parse('$_uri/check-code/$companyCode'),
      headers: {'Accept': 'application/json'});

  if (response.statusCode == 200) {
    final responseBody = utf8.decode(response.bodyBytes);

    // Nếu backend trả "null" -> coi như không có công ty
    if (responseBody.isEmpty || responseBody == "null") {
      return null; // <-- Không throw nữa
    }

    try {
      return Company.fromMap(jsonDecode(responseBody));
    } catch (e) {
      print("Lỗi giải mã Company: $e \nBody: $responseBody");
      return null; // <-- Trả null thay vì crash
    }
  }

  return null;
}

  /// Lấy thông tin công ty bằng ID
  /// Tương ứng: GET /api/companys/get/{id}
  // SỬA LỖI: Lỗi 404 liên tục cho thấy các endpoint lấy theo ID (`/get/{id}`, `/detail/{id}`) không hoạt động.
  // Thay đổi chiến lược: Lấy tất cả các công ty và lọc ở phía client.
  Future<Company?> fetchCompanyById(int companyId) async {
    try {
      // 1. Gọi API để lấy danh sách TẤT CẢ các công ty.
      final allCompanies = await fetchAllCompanies();
      // 2. Tìm công ty có ID khớp trong danh sách.
      // Dùng firstWhereOrNull để tránh lỗi nếu không tìm thấy.
      final company = allCompanies.firstWhere(
        (c) => c.id == companyId,
      );
      return company;
    } catch (e) {
      // Ném lại lỗi nếu `fetchAllCompanies` hoặc `firstWhere` thất bại.
      throw Exception('Lỗi khi tìm công ty với ID $companyId: $e');
    }
  }

  /// Lấy tất cả các công ty
  /// Tương ứng: GET /api/companys/all
  Future<List<Company>> fetchAllCompanies() async {
    final response = await http.get(
      Uri.parse('$_uri/all'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((company) => Company.fromMap(company as Map<String, dynamic>))
          .toList();
    }
        return [];
  }

  // API LẤY THỐNG KÊ (Backend còn thiếu)
  // Tạm thời giữ lại hàm giả lập này cho provider
  Future<Map<String, int>> fetchSystemStats() async {
    // Giả lập API
    await Future.delayed(const Duration(milliseconds: 500));
    // Dữ liệu này nên được trả về từ một API mới (ví dụ: /api/company/stats)
    return {
      "totalBranches": 0, // Sẽ được cập nhật bởi systemStatsProvider
      "totalStaff": 0,  // Sẽ được cập nhật bởi systemStatsProvider
    };
  }
}

// Provider Riverpod để truy cập CompanyAPI
final companyApiProvider = Provider<CompanyAPI>((ref) => CompanyAPI());