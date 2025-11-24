// file: lib/API/user_branch_API.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final _relationUri = 'https://smartdine-backend-oq2x.onrender.com/api/user-branches';

// Model Dart cho UserBranch (để gửi và nhận)
class UserBranch {
  final int userId;
  final int branchId;
  final String? assignedAt;

  UserBranch({required this.userId, required this.branchId, this.assignedAt});
  
  Map<String, dynamic> toMap() => {'userId': userId, 'branchId': branchId};
  
  factory UserBranch.fromMap(Map<String, dynamic> map) {
    return UserBranch(
      userId: map['userId'] as int,
      branchId: map['branchId'] as int,
      assignedAt: map['assignedAt'] as String?,
    );
  }
}

class UserBranchAPI {
  // Lấy tất cả quan hệ (GET /api/user-branches/all)
  Future<List<UserBranch>> fetchAllRelations() async {
     final response = await http.get(Uri.parse('$_relationUri/all'),
        headers: {'Accept': 'application/json'});
     if (response.statusCode == 200) {
       List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
       return body.map((dynamic item) => UserBranch.fromMap(item)).toList();
     } else { 
       throw Exception('Lỗi tải quan hệ User-Branch (Mã: ${response.statusCode})'); 
     }
  }

  // Lấy UserBranch theo Branch ID (GET /api/user-branches/branch/{branchId})
  Future<List<UserBranch>> fetchRelationsByBranch(int branchId) async {
     final response = await http.get(Uri.parse('$_relationUri/branch/$branchId'),
        headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => UserBranch.fromMap(item)).toList();
      } else { 
         throw Exception('Lỗi tải quan hệ cho chi nhánh (Mã: ${response.statusCode})');
      }
  }

  // Gán User vào Branch (POST /api/user-branches)
  Future<UserBranch> assignUserToBranch(int userId, int branchId) async {
     final body = jsonEncode({ 'userId': userId, 'branchId': branchId });
     final response = await http.post(
       Uri.parse('$_relationUri'),
       headers: {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json'},
       body: body,
     );
     if (response.statusCode == 200 || response.statusCode == 201) {
       return UserBranch.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
     } else {
       throw Exception('Lỗi gán nhân viên (Mã: ${response.statusCode}) - ${utf8.decode(response.bodyBytes)}');
     }
  }
  // SỬA: Thêm branchId để xóa đúng quan hệ
  Future<bool> unassignUserFromBranch(int userId) async {
     final response = await http.delete(
       Uri.parse('$_relationUri/user/$userId'), // SỬA: Endpoint mới
       headers: <String, String>{
         'Accept': 'application/json',
         // 'Authorization': 'Bearer YOUR_TOKEN',
       },
     );
     
     if (response.statusCode == 200 || response.statusCode == 204) {
       return true; // Thành công
     } else {
       throw Exception('Lỗi xóa nhân viên khỏi chi nhánh (Mã: ${response.statusCode})');
     }
  }
}

final userBranchApiProvider = Provider<UserBranchAPI>((ref) => UserBranchAPI());