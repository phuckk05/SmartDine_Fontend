import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mart_dine/models/company.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/companys';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/companys';

class CompanyAPI {
  //Lấy tất cả company
  Future<List<Company>> getAllCompanys() async {
    final response = await http.get(
      Uri.parse('$uri2/all'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((company) => Company.fromMap(company as Map<String, dynamic>))
          .toList();
    }
    print("loi lấy companys: ${response.statusCode}");
    return [];
  }

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
      Uri.parse('$uri2/$companyCode'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return Company.fromMap(data);
    }
    return null;
  }
}

final companyApiProvider = StateProvider<CompanyAPI>((ref) => CompanyAPI());
