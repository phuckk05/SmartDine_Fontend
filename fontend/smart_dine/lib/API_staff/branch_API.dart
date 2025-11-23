import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/model_staff/branch.dart';
import 'dart:convert';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/branches';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/branches';

class BranchAPI {
  //Tạo branch
  Future<Branch?> create(Branch branch) async {
    final response = await http.post(
      Uri.parse(uri2),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(branch.toMap()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Branch.fromMap(data);
    }
    return null;
  }

  Future<Branch?> findBranchByBranchCode(String branchCode) async {
    final response = await http.get(
      Uri.parse('$uri2/$branchCode'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Branch.fromMap(data);
    }
    return null;
  }

  Future<List<Branch>?> getBranchesByCompanyId(int companyId) async {
    final response = await http.get(
      Uri.parse('$uri2/company/$companyId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Branch.fromMap(item)).toList();
    }
    return null;
  }

  Future<Branch?> getBranchById(int branchId) async {
    final response = await http.get(
      Uri.parse('$uri2/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Branch.fromMap(data);
    }
    return null;
  }
}

//userApiProvider
final branchApiProvider2 = Provider<BranchAPI>((ref) => BranchAPI());
