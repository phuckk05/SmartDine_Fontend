import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserApprovalAPI {
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api/user-approval';

  // Lấy danh sách user bị khóa theo branch (status = 0)
  Future<List<User>> getPendingUsersByBranch(int branchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/locked/branch/$branchId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting locked users: $e');
      return [];
    }
  }

  // Lấy danh sách user chờ duyệt theo company  
  Future<List<User>> getPendingUsersByCompany(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pending/company/$companyId'),
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

  // Duyệt user (chuyển từ status 0 sang status 1)
  Future<bool> approveUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/activate/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error approving user: $e');
      return false;
    }
  }

  // Từ chối user
  Future<bool> rejectUser(int userId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reject/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting user: $e');
      return false;
    }
  }

  // Block user
  Future<bool> blockUser(int userId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/block/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }

  // Lấy thống kê pending users
  Future<Map<String, int>> getPendingStatistics(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/$companyId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      print('Error getting pending statistics: $e');
      return {};
    }
  }
}