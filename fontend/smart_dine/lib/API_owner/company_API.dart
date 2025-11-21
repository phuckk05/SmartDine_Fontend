// file: lib/API/company_api.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/company.dart'; 

final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/companys';

class CompanyAPI {
  /// Lấy thông tin công ty bằng mã code
  /// Tương ứng: GET /api/companys/{companyCode}
  Future<Company?> fetchCompanyByCode(String companyCode) async {
  final response = await http.get(Uri.parse('$_uri/$companyCode'),
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
  Future<Company?> fetchCompanyById(int companyId) async {
    final response = await http.get(Uri.parse('$_uri/get/$companyId'),
        headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      if (responseBody.isEmpty || responseBody == "null") {
        return null;
      }
      try {
        return Company.fromMap(jsonDecode(responseBody));
      } catch (e) {
        print("Lỗi giải mã Company by ID: $e \nBody: $responseBody");
        return null;
      }
    }
    return null;
  }

  /// Lấy tất cả các công ty
  /// Tương ứng: GET /api/companys/all
  Future<List<Company>> fetchAllCompanies() async {
    final response = await http.get(Uri.parse('$_uri/all'),
        headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Company.fromMap(item)).toList();
      } catch (e) {
        throw Exception('Lỗi giải mã danh sách Công ty: $e');
      }
    } else {
      throw Exception('Lỗi tải danh sách Công ty (Mã: ${response.statusCode})');
    }
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