import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mart_dine/models/company.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/companys';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/companys';

class CompanyAPI {
  //Đăng kí company
  Future<Company?> createCompany(Company company) async {
    final response = await http.post(
      Uri.parse(uri2),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(company.toMap()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Company.fromMap(data);
    }
    return null;
  }

  //Kiểm tra companyCode
  Future<Company?> exitsCompanyCode(String companyCode) async {
    final response = await http.get(
      Uri.parse('${uri2}/${companyCode}'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return Company.fromMap(data);
    }
    return null;
  }

  // Lấy danh sách công ty chờ xác nhận
  Future<List<Company>> getPendingCompanies() async {
    final response = await http.get(Uri.parse('$uri2/pending'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Company.fromMap(e)).toList();
    }
    throw Exception('Lỗi khi lấy danh sách công ty chờ duyệt');
  }

  // Duyệt công ty
  Future<void> approveCompany(int id) async {
    final response = await http.put(Uri.parse('$uri2/approve/$id'));
    if (response.statusCode != 200) {
      throw Exception('Không thể duyệt công ty');
    }
  }

  // Từ chối công ty
  Future<void> rejectCompany(int id) async {
    final response = await http.put(Uri.parse('$uri2/reject/$id'));
    if (response.statusCode != 200) {
      throw Exception('Không thể từ chối công ty');
    }
  }

  // Xóa công ty
  Future<void> deleteCompany(int id) async {
    final response = await http.delete(Uri.parse('$uri2/delete/$id'));
    if (response.statusCode != 200) {
      throw Exception('Không thể xóa công ty');
    }
  }
}

final companyApiProvider = StateProvider<CompanyAPI>((ref) => CompanyAPI());
