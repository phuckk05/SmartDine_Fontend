import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

// Backend API endpoints
final uri1 = 'https://spring-boot-smartdine.onrender.com/api/users';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/users';

class UserAPI {
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

      print('🔍 [API] Login response status: ${response.statusCode}');
      print('🔍 [API] Login response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('Empty response body');
          return null;
        }
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('🔍 [API] Parsed user data: $data');

        final user = User.fromMap(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toMap()));

        print('🔍 [API] User object - id: ${user.id}, name: ${user.fullName}');
        return user;
      }
      return null;
    } catch (e) {
      print('🔍 [API] Login error: $e');
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
}

//userApiProvider
final userApiProvider = Provider<UserAPI>((ref) => UserAPI());
