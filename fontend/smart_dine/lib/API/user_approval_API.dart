import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'user_API.dart';
import 'employee_management_API.dart';

class UserApprovalAPI {
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';
  final UserAPI _userAPI = UserAPI();

  // Lấy danh sách nhân viên chờ duyệt (statusId = 3) từ tất cả users
  Future<List<User>> getPendingUsersByBranch(int branchId) async {
    try {
      return await _userAPI.getPendingUsers();
    } catch (e) {
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

  // Duyệt nhân viên (chuyển từ statusId 3 → statusId 1)
  Future<bool> approveUser(int userId) async {
    try {
      // Get current user data first
      final currentUser = await _userAPI.getUserById(userId);
      if (currentUser == null) {
        return false;
      }
      
      // Create updated user with statusId = 1 (approved)
      final approvedUser = currentUser.copyWith(
        statusId: 1,
        updatedAt: DateTime.now(),
        statusName: 'Hoạt động',
      );
      
      // Use EmployeeManagementAPI to update (same as edit function)
      final employeeAPI = EmployeeManagementAPI();
      await employeeAPI.updateEmployee(userId, approvedUser);
      
      // Return true if update successful (result may be null due to response format)
      return true;
    } catch (e) {
      return false;
    }
  }

  // Từ chối user
  Future<bool> rejectUser(int userId, String reason) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reject/$userId?reason=${Uri.encodeComponent(reason)}'),
        headers: {'Content-Type': 'application/json'},
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
      final response = await http.put(
        Uri.parse('$baseUrl/block/$userId?reason=${Uri.encodeComponent(reason)}'),
        headers: {'Content-Type': 'application/json'},
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