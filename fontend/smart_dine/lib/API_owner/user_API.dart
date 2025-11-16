// file: lib/API/user_API.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/user.dart'; // Model User Flutter

// !!! THAY ĐỔI URL !!!
final _userUri = 'https://smartdine-backend-oq2x.onrender.com/api/users';

class UserAPI {
  // Lấy tất cả user (GET /api/users/all)
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$_userUri/all'),
        headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => User.fromMap(item as Map<String, dynamic>)).toList();
      } catch (e) {
        print("Lỗi decode users: $e \nResponse body: ${utf8.decode(response.bodyBytes)}");
        throw Exception('Lỗi giải mã dữ liệu người dùng.');
      }
    } else {
      throw Exception('Lỗi tải danh sách người dùng (Mã: ${response.statusCode})');
    }
  }

  // Lấy user theo ID (GET /api/users/get/{id})
  Future<User> fetchUserById(int userId) async {
     final response = await http.get(Uri.parse('$_userUri/get/$userId'),
         headers: {'Accept': 'application/json'});
     if (response.statusCode == 200) {
       try {
         return User.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
       } catch (e) {
         throw Exception('Lỗi giải mã dữ liệu người dùng.');
       }
     } else {
        throw Exception('Lỗi tải người dùng (Mã: ${response.statusCode})');
     }
  }

  // Cập nhật user (PUT /api/users/update/{id})
  Future<User> updateUser(int userId, User user) async {
    Map<String, dynamic> userMap = user.toMap();
    // Đảm bảo gửi đúng định dạng thời gian
    userMap['createdAt'] = user.createdAt.toIso8601String();
    userMap['updatedAt'] = DateTime.now().toIso8601String();
    if (user.deletedAt != null) {
        userMap['deletedAt'] = user.deletedAt!.toIso8601String();
    }
    
    final response = await http.put(
      Uri.parse('$_userUri/update/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(userMap),
    );
     if (response.statusCode == 200) {
       try {
         return User.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
       } catch (e) {
         throw Exception('Lỗi giải mã người dùng đã cập nhật.');
       }
     } else {
        throw Exception('Lỗi cập nhật người dùng (Mã: ${response.statusCode}) - ${utf8.decode(response.bodyBytes)}');
     }
  }

  // Xóa user (DELETE /api/users/delete/{id})
  Future<bool> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('$_userUri/delete/$userId'),
      headers: <String, String>{ 'Accept': 'application/json' },
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
       return true;
    } else {
        throw Exception('Lỗi xóa người dùng (Mã: ${response.statusCode})');
    }
  }
  
  // SỬA: Workaround cho API /search bị thiếu
  Future<List<User>> fetchUsersByCompanyAndRole(int companyId, int roleId) async {
    // 1. Gọi API /all (vì /search không tồn tại)
    final response = await http.get(
      Uri.parse('$_userUri/all'), 
      headers: {'Accept': 'application/json'}
    );
    
    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<User> allUsers = body.map((dynamic item) => User.fromMap(item)).toList();
        
        // 2. Tự lọc kết quả ở client
        List<User> filteredUsers = allUsers.where((user) {
          return user.companyId == companyId && user.role == roleId;
        }).toList();

        return filteredUsers;
        
      } catch (e) { throw Exception('Lỗi giải mã User'); }
    } else if (response.statusCode == 404) {
      return []; // Không tìm thấy
    } else {
      throw Exception('Lỗi tải Owner (Mã: ${response.statusCode})');
    }
  }
}

final userApiProvider = Provider<UserAPI>((ref) => UserAPI());