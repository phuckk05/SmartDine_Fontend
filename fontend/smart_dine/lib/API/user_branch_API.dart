import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final _uri = Uri.parse(
  'https://spring-boot-smartdine.onrender.com/api/user_branches',
);

class UserBranchAPI {
  //Tạo user
  Future<bool> create(int userId, int branchId) async {
    final now = DateTime.now();
    final response = await http.post(
      _uri,
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
    print("loi crated uerbranch : ${response.statusCode}");
    return false;
  }
}

//userApiProvider
final userBranchApiProvider = Provider<UserBranchAPI>((ref) => UserBranchAPI());
