import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

// Backend API endpoints
final uri1 = 'https://spring-boot-smartdine.onrender.com/api/users';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/users';

class UserAPI {
  // ...existing code...
  //Tạo user
  Future<User?> createUser(User user) async {
    final response = await http.post(
      Uri.parse(uri2),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toMap()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromMap(data);
    }
    print(
      '[API] Create user failed: ${response.statusCode} ${response.body}',
    );
    return null;
  }

  //Đăng nhập user
  Future<User?> signIn(String email) async {
    final response = await http.get(
      Uri.parse('$uri2/email/${Uri.encodeComponent(email)}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final user = User.fromMap(data);

      /// Lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toMap()));

      return user;
    }

    return null;
  }

  //Đăng nhập user
  Future<User?> signIn2(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$uri2/email/${Uri.encodeComponent(email)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return null;
        }
        final Map<String, dynamic> data = jsonDecode(response.body);
        // print('🔍 [API] Parsed user data: $data');

        // final user = User.fromMap(data);
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('user', jsonEncode(user.toMap()));

        // print('🔍 [API] User object - id: ${user.id}, name: ${user.fullName}');

        final user = User.fromMap(data);

        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //Update user
  Future<User?> updatePassword(int userId, String newPassword) async {
    final uri = Uri.parse(
      '$uri2/password/$userId',
    ).replace(queryParameters: {'newPassword': newPassword});
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromMap(data);
    }
    return null;
  }

  //Cập nhật lại comapnyId cho user
  Future<User?> updateCompanyId(int userId, int companyId) async {
    final uri = Uri.parse('$uri2/$userId/company/$companyId');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromMap(data);
    }
    return null;
  }

  // Lấy user theo ID - Uses /all endpoint and filters by ID
  Future<User?> getUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$uri2/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final userMap = data.firstWhere(
          (user) => (user['id'] ?? 0) == userId,
          orElse: () => null,
        );

        if (userMap != null) {
          return User.fromMap(Map<String, dynamic>.from(userMap));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user status (for approval functionality) - DEPRECATED
  // Use EmployeeManagementAPI.updateEmployee() instead
  @deprecated
  Future<bool> updateUserStatus(int userId, int statusId) async {
    return false;
  }

  // Get all users with pending status (statusId = 3)
  Future<List<User>> getPendingUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$uri2/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final allUsers = data.map((json) => User.fromMap(json)).toList();

        // Filter only pending users (statusId = 3)
        return allUsers.where((user) => user.statusId == 3).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

//userApiProvider
final userApiProvider = Provider<UserAPI>((ref) => UserAPI());
