import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/user-branches';
final uri1 = 'https://spring-boot-smartdine.onrender.com/api/user-branches';

class UserBranchAPI {
  //Tạo user
  Future<bool> create(int userId, int branchId) async {
    final now = DateTime.now();
    final response = await http.post(
      Uri.parse(uri2),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'branchId': branchId,
        'assignedAt': now.toIso8601String(),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
        return false;
  }

  //Lấy userBranch theo userId
  Future<Map<String, dynamic>?> getBranchByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$uri2/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }
        return null;
  }

  //Update password userBranch
  Future<bool> updatePassword(int userId, String newPassword) async {
    final response = await http.put(
      Uri.parse('$uri2/update/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'newPassword': newPassword,
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
        return false;
  }
}

//userApiProvider
final userBranchApiProvider = Provider<UserBranchAPI>((ref) => UserBranchAPI());
