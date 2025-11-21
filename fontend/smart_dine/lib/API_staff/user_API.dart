import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model_staff/user.dart';

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
      return User.fromMap(data);
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

      print('SignIn Response Status: ${response.statusCode}');
      print('SignIn Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('Empty response body');
          return null;
        }
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromMap(data);
      }
      return null;
    } catch (e) {
      print('SignIn Error: $e');
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
}

//userApiProvider
final userApiProvider = Provider<UserAPI>((ref) => UserAPI());
