import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Role {
  final int id;
  final String code;
  final String name;

  Role({required this.id, required this.code, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }
}

class RolesNotifier extends StateNotifier<List<Role>> {
  RolesNotifier() : super([]) {
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final response = await http.get(Uri.parse('https://smartdine-backend-oq2x.onrender.com/api/roles/all'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        state = data.map((json) => Role.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback to default roles if API fails
      state = [
        Role(id: 1, code: 'ADMIN', name: 'Admin'),
        Role(id: 2, code: 'MANAGER', name: 'Quản lý'),
        Role(id: 3, code: 'STAFF', name: 'Nhân viên oder'),
        Role(id: 4, code: 'CHEF', name: 'Đầu bếp'),
        Role(id: 5, code: 'OWNER', name: 'Chủ cửa hàng'),
        Role(id: 6, code: 'Cashier', name: 'Thu ngân'),
      ];
    }
  }
}

final rolesProvider = StateNotifierProvider<RolesNotifier, List<Role>>((ref) {
  return RolesNotifier();
});

// Provider để lấy tên role theo ID
final getRoleNameProvider = Provider.family<String, int?>((ref, roleId) {
  final roles = ref.watch(rolesProvider);
  if (roleId == null) return 'Không xác định';
  final role = roles.firstWhere(
    (r) => r.id == roleId,
    orElse: () => Role(id: -1, code: 'UNKNOWN', name: 'Không xác định'),
  );
  return role.name;
});