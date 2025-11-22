import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../core/services/http_service.dart';

final employeeManagementApiProvider = Provider((ref) => EmployeeManagementAPI());

class EmployeeManagementAPI {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';

  // Helper để parse response
  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    }
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  // Lấy tất cả nhân viên
  Future<List<User>?> getAllEmployees() async {
    try {
      final response = await _httpService.get('$baseUrl/employees');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> employees;
        if (data is Map<String, dynamic> && data['data'] != null) {
          employees = data['data'];
        } else if (data is List) {
          employees = data;
        } else {
          return [];
        }
  return employees.map((json) => User.fromMap(Map<String, dynamic>.from(json))).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }

  // Lấy danh sách nhân viên theo chi nhánh
  Future<List<User>?> getEmployeesByBranch(int branchId) async {
    try {
      print('🔍 [EmployeeAPI] Fetching employees for branchId: $branchId');
      final response = await _httpService.get('$baseUrl/employees/branch/$branchId');
      print('🔍 [EmployeeAPI] Response status: ${response.statusCode}');
      print('🔍 [EmployeeAPI] Response body: ${response.body}');
      
      final data = _parseResponse(response);
      print('🔍 [EmployeeAPI] Parsed data type: ${data.runtimeType}');
      
      if (data != null) {
        List<dynamic> employees;
        if (data is Map<String, dynamic> && data['data'] != null) {
          employees = data['data'];
        } else if (data is List) {
          employees = data;
        } else {
          print('❌ [EmployeeAPI] Unexpected data structure: $data');
          return [];
        }
        
        print('🔍 [EmployeeAPI] Found ${employees.length} employees');
        final users = employees.map((json) {
          print('🔍 [EmployeeAPI] Processing employee: ${json['fullName'] ?? json['full_name']}');
          return User.fromMap(Map<String, dynamic>.from(json));
        }).toList();
        
        print('✅ [EmployeeAPI] Successfully parsed ${users.length} users');
        return users;
      }
      print('❌ [EmployeeAPI] No data returned');
      return [];
    } catch (e) {
      print('❌ [EmployeeAPI] Error: $e');
      return null;
    }
  }

  // Lấy thông tin nhân viên theo ID
  Future<User?> getEmployeeById(int employeeId) async {
    try {
      final response = await _httpService.get('$baseUrl/employees/$employeeId');
      final data = _parseResponse(response);
      
      if (data != null) {
        if (data is Map<String, dynamic>) {
          if (data['data'] != null) {
            return User.fromMap(data['data']);
          } else {
            return User.fromMap(data);
          }
        }
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Thêm nhân viên mới
  Future<User?> addEmployee(User employee) async {
    try {
      final response = await _httpService.post(
        '$baseUrl/employees',
        body: jsonEncode(employee.toMap()),
      );
      final data = _parseResponse(response);
      
      if (data != null && data is Map<String, dynamic>) {
        if (data['data'] != null) {
          return User.fromMap(data['data']);
        } else {
          return User.fromMap(data);
        }
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Cập nhật thông tin nhân viên
  Future<User?> updateEmployee(int employeeId, User employee) async {
    try {
      final response = await _httpService.put(
        '$baseUrl/employees/$employeeId',
        body: jsonEncode(employee.toMap()),
      );
      final data = _parseResponse(response);
      
      if (data != null && data is Map<String, dynamic>) {
        if (data['data'] != null) {
          return User.fromMap(data['data']);
        } else {
          return User.fromMap(data);
        }
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Xóa nhân viên
  Future<bool> deleteEmployee(int employeeId) async {
    try {
      final response = await _httpService.delete('$baseUrl/employees/$employeeId');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
            return false;
    }
  }

  // Lấy hiệu suất nhân viên theo chi nhánh
  Future<Map<String, dynamic>?> getEmployeePerformance(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/employees/performance/branch/$branchId');
      final data = _parseResponse(response);
      
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Gán nhân viên vào chi nhánh
  Future<bool> addEmployeeToBranch(int branchId, User employee) async {
    try {
      // First create the employee
      final createdEmployee = await addEmployee(employee);
      if (createdEmployee == null || createdEmployee.id == null) {
        return false;
      }

      // Then assign to branch
      final response = await _httpService.post(
        '$baseUrl/employees/${createdEmployee.id}/assign-branch/$branchId',
        body: jsonEncode({}),
      );
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
            return false;
    }
  }

  // Bỏ gán nhân viên khỏi chi nhánh
  Future<bool> removeEmployeeFromBranch(int employeeId, int branchId) async {
    try {
      final response = await _httpService.delete('$baseUrl/employees/$employeeId/remove-branch/$branchId');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
            return false;
    }
  }

  // Lấy danh sách vai trò
  Future<List<Map<String, dynamic>>?> getRoles() async {
    try {
      final response = await _httpService.get('$baseUrl/roles/all');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> roles;
        if (data is Map<String, dynamic> && data['data'] != null) {
          roles = data['data'];
        } else if (data is List) {
          roles = data;
        } else {
          return [];
        }
        return roles.map((role) => Map<String, dynamic>.from(role)).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }

  // Lấy danh sách trạng thái user
  Future<List<Map<String, dynamic>>?> getUserStatuses() async {
    try {
      final response = await _httpService.get('$baseUrl/user-statuses');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> statuses;
        if (data is Map<String, dynamic> && data['data'] != null) {
          statuses = data['data'];
        } else if (data is List) {
          statuses = data;
        } else {
          return [];
        }
        return statuses.map((status) => Map<String, dynamic>.from(status)).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }
}