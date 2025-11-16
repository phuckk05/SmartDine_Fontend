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
    } catch (e) {}
    return [];
  }

  // Lấy branch theo ID với permission check và fallback tốt hơn
  Future<Branch?> getBranchById(String branchId, {int? userId}) async {
    try {
      final targetBranchId = int.tryParse(branchId) ?? 0;
      
      // Nếu có userId, thử sử dụng permission-based endpoint trước
      if (userId != null) {
        try {
          final response = await http.get(
            Uri.parse('https://smartdine-backend-oq2x.onrender.com/api/users/$userId/branches/$targetBranchId/full'),
            headers: {'Content-Type': 'application/json'},
          );
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return Branch.fromMap(Map<String, dynamic>.from(data));
          }
          
          // Nếu permission endpoint fail, log nhưng vẫn fallback
          print('Permission endpoint failed with status: ${response.statusCode}');
        } catch (permissionError) {
          print('Permission endpoint error: $permissionError');
        }
      }
      
      // Fallback: Lấy tất cả branches và tìm branch cần thiết
      final response = await http.get(
        Uri.parse(_uri),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Tìm branch có ID khớp
        final branchData = data.firstWhere(
          (branch) => (branch['id'] ?? 0) == targetBranchId,
          orElse: () => null,
        );
        
        if (branchData != null) {
          return Branch.fromMap(Map<String, dynamic>.from(branchData));
        }
      }
      
      // Nếu không tìm được, thử endpoint branch cụ thể
      final singleResponse = await http.get(
        Uri.parse('$_uri/$targetBranchId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (singleResponse.statusCode == 200) {
        final data = jsonDecode(singleResponse.body);
        return Branch.fromMap(Map<String, dynamic>.from(data));
      }
      
    } catch (e) {
      print('Error getting branch by ID: $e');
      // Không rethrow để tránh crash ứng dụng
    }
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
