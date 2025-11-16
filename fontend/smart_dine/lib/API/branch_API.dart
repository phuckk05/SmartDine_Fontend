import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/branch.dart';
import 'dart:convert';

final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/branches';

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
      debugPrint(
        'BranchAPI.create failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      debugPrint('BranchAPI.create error: $e');
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
    } catch (e) {}
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
    } catch (e) {}
    return null;
  }

  Future<Branch?> findBranchByBranchCode(String branchCode) async {
    final response = await http.get(
      Uri.parse('${_uri}/${branchCode}'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Branch.fromMap(data);
    }
    return null;
  }

  // Lấy chi nhánh theo manager ID (cho role Manager)
  // Filter từ danh sách tất cả branches để tìm branch có managerId khớp
  Future<Branch?> getBranchByManagerId(int managerId) async {
    try {
      final allBranches = await getAllBranches();

      // Tìm branch có managerId trùng với userId
      for (final branch in allBranches) {
        if (branch.managerId != 0 && branch.managerId == managerId) {
          return branch;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
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
