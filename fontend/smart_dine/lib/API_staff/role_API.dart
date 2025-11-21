import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/model_staff/role.dart';
import 'dart:convert';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/roles';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/roles';

class RoleAPI {
  //Lấy tất cả role
  Future<List<Role>?> getAll() async {
    final response = await http.get(
      Uri.parse(uri2),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Role.fromJson(e)).toList();
    }
    print("loi lay all role : ${response.statusCode}");
    return null;
  }

  //Lấy role theo id
  Future<Role?> getById(int id) async {
    final response = await http.get(
      Uri.parse('$uri2/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Role.fromMap(data);
    }
    print("loi lay role by id : ${response.statusCode}");
    return null;
  }
}

final roleApiProvider = Provider<RoleAPI>((ref) => RoleAPI());
