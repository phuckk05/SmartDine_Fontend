import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class UserAPI {
  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('https://spring-boot-smartdine.onrender.com/users'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách người dùng');
    }
  }

  Future<User> updateUser(int id, String name, String email) async {
    final response = await http.put(
      Uri.parse('https://spring-boot-smartdine.onrender.com/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Không thể cập nhật user');
    }
  }
}
