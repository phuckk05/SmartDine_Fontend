// file: lib/API/role_API.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/role.dart'; // Model Role Flutter (đã sửa int id)

final _roleUri = 'https://smartdine-backend-oq2x.onrender.com/api/roles';

class RoleAPI {
  // Lấy tất cả role (GET /api/roles/all)
  Future<List<Role>> fetchRoles() async {
    final response = await http.get(Uri.parse('$_roleUri/all'),
        headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        // Model Role Java (int id) -> Model Role Flutter (int id)
        return body.map((dynamic item) => Role.fromMap(item)).toList();
      } catch (e) {
        print("Lỗi decode roles: $e \nBody: ${utf8.decode(response.bodyBytes)}");
        throw Exception('Lỗi giải mã dữ liệu vai trò.');
      }
    } else {
      throw Exception('Lỗi tải danh sách vai trò (Mã: ${response.statusCode})');
    }
  }
}

final roleApiProvider = Provider<RoleAPI>((ref) => RoleAPI());