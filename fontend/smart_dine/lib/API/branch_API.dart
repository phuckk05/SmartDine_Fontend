import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/branch.dart';
import 'dart:convert';

final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/branches';

class BranchAPI {
  // Lấy thông tin branch theo branchCode
  Future<Branch?> findBranchByBranchCode(String branchCode) async {
    try {
      print('🔄 Calling API: $_uri/$branchCode');
      final response = await http.get(
        Uri.parse('$_uri/$branchCode'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 API Response status: ${response.statusCode}');
      print('📝 API Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Branch.fromMap(data);
      }
      print('❌ API call failed with status: ${response.statusCode}');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error finding branch by code: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  // Lấy thống kê branch
  Future<Map<String, dynamic>?> getBranchStatistics(int branchId) async {
    try {
      print('🔄 Calling API: $_uri/$branchId/statistics');
      final response = await http.get(
        Uri.parse('$_uri/$branchId/statistics'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 API Response status: ${response.statusCode}');
      print('📝 API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('❌ API call failed with status: ${response.statusCode}');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error getting branch statistics: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  // Lấy tất cả branches
  Future<List<Branch>?> getAllBranches() async {
    try {
      print('🔄 Calling API: $_uri');
      final response = await http.get(
        Uri.parse(_uri),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 API Response status: ${response.statusCode}');
      print('📝 API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Branch.fromMap(json)).toList();
      }
      print('❌ API call failed with status: ${response.statusCode}');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error getting all branches: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }
}

// Provider cho BranchAPI
final branchApiProvider = Provider<BranchAPI>((ref) => BranchAPI());