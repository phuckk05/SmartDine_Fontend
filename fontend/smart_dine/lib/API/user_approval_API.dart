import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

// Backend API endpoints
final uri1 = 'https://spring-boot-smartdine.onrender.com/api/user-approval';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/user-approval';

class UserApprovalAPI {
  
  // Lấy danh sách user chờ duyệt theo companyId
  Future<List<User>> getPendingUsersByCompany(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse('$uri2/pending/$companyId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting pending users by company: $e');
      return [];
    }
  }

  // Lấy danh sách user chờ duyệt theo branchId  
  Future<List<User>> getPendingUsersByBranch(int branchId) async {
    try {
      final response = await http.get(
        Uri.parse('$uri2/pending/branch/$branchId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting pending users by branch: $e');
      return [];
    }
  }

  // Duyệt user (statusId 3 -> 1)
  Future<bool> approveUser(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$uri2/approve/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error approving user: $e');
      return false;
    }
  }

  // Từ chối user (statusId 3 -> 2)
  Future<bool> rejectUser(int userId, {String? reason}) async {
    try {
      String url = '$uri2/reject/$userId';
      if (reason != null && reason.isNotEmpty) {
        url += '?reason=${Uri.encodeComponent(reason)}';
      }
      
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting user: $e');
      return false;
    }
  }

  // Khóa user
  Future<bool> blockUser(int userId, {String? reason}) async {
    try {
      String url = '$uri2/block/$userId';
      if (reason != null && reason.isNotEmpty) {
        url += '?reason=${Uri.encodeComponent(reason)}';
      }
      
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }

  // Lấy thống kê user chờ duyệt
  Future<Map<String, int>?> getPendingStatistics(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse('$uri2/statistics/$companyId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.cast<String, int>();
      }
      return null;
    } catch (e) {
      print('Error getting pending statistics: $e');
      return null;
    }
  }
}

// Provider cho UserApprovalAPI
final userApprovalAPIProvider = Provider<UserApprovalAPI>((ref) {
  return UserApprovalAPI();
});