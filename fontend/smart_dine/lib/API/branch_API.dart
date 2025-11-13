import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/branch.dart';
import 'dart:convert';

final _uri = 'https://spring-boot-smartdine.onrender.com/api/branches';

class BranchAPI {
  // Tạo branch
  Future<Branch?> create(Branch branch) async {
    try {
      final response = await http.post(
        Uri.parse('$_uri'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(branch.toMap()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Branch.fromMap(data);
      }
    } catch (e) {
          }
    return null;
  }

  // Lấy tất cả branches
  Future<List<Branch>> getAllBranches() async {
    try {
      final response = await http.get(
        Uri.parse(_uri),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Branch.fromMap(json)).toList();
      }
    } catch (e) {
          }
    return [];
  }

  // Lấy branch theo ID
  Future<Branch?> getBranchById(String branchId) async {
    try {
      final response = await http.get(
        Uri.parse('$_uri/$branchId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Branch.fromMap(data);
      }
    } catch (e) {
          }
    return null;
  }

  Future<Branch?> findBranchByBranchCode(String branchCode) async {
    final response = await http.get(
      Uri.parse('${_uri}/code/${branchCode}'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Branch.fromMap(data);
    }
    return null;
  }

  // Lấy thống kê branch
  Future<Map<String, dynamic>?> getBranchStatistics(int branchId) async {
    try {
            final response = await http.get(
        Uri.parse('$_uri/$branchId/statistics'),
        headers: {'Content-Type': 'application/json'},
      );
      
                  if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
            return null;
    } catch (e) {
      return null;
    }
  }
}

// Provider cho BranchAPI
final branchApiProvider = Provider<BranchAPI>((ref) => BranchAPI());