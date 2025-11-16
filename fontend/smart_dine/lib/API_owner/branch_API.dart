// file: lib/API/branch_API.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
// Đảm bảo đường dẫn đến model Branch của bạn là chính xác
import 'package:mart_dine/models_owner/branch.dart'; 

// !!! THAY ĐỔI URL NÀY THÀNH ĐỊA CHỈ BACKEND CỦA BẠN !!!
final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/branches';
// final _uri = 'http://localhost:8080/api/branches'; // Dùng khi chạy local

class BranchAPI {
  // Lấy tất cả chi nhánh (GET /api/branches/all)
  Future<List<Branch>> fetchBranches() async {
    final response = await http.get(Uri.parse(_uri),
        headers: {'Accept': 'application/json'}
    );

    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<Branch> branches = body.map((dynamic item) => Branch.fromMap(item as Map<String, dynamic>)).toList();
        return branches;
      } catch (e) {
         print("Lỗi decode branches: $e \nResponse body: ${utf8.decode(response.bodyBytes)}");
         throw Exception('Lỗi giải mã dữ liệu chi nhánh.');
      }
    } else {
      print("Lỗi tải branches. Status: ${response.statusCode} \nBody: ${utf8.decode(response.bodyBytes)}");
      throw Exception('Lỗi tải danh sách chi nhánh (Mã: ${response.statusCode})');
    }
  }

  // Tìm chi nhánh theo mã code (GET /api/branches/{branchCode})
  Future<Branch?> findBranchByBranchCode(String branchCode) async {
    final response = await http.get(
      Uri.parse('$_uri/$branchCode'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
       try {
            final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
            return Branch.fromMap(data);
       } catch (e) {
            print("Lỗi decode branch by code: $e \nResponse body: ${utf8.decode(response.bodyBytes)}");
            throw Exception('Lỗi giải mã dữ liệu chi nhánh.');
       }
    } else if (response.statusCode == 404) {
        print('Không tìm thấy chi nhánh với mã: $branchCode');
        return null;
    }
    else {
        print("Lỗi tải branch by code. Status: ${response.statusCode} \nBody: ${utf8.decode(response.bodyBytes)}");
        throw Exception('Lỗi tải chi nhánh (Mã: ${response.statusCode})');
    }
  }

  // Tạo chi nhánh mới (POST /api/branches)
  Future<Branch> createBranch(Branch branch) async {
     final Map<String, dynamic> branchMap = branch.toMap();
     branchMap.remove('id'); // ID do backend tạo
     branchMap['createdAt'] = branch.createdAt.toIso8601String();
     branchMap['updatedAt'] = branch.updatedAt.toIso8601String();

     final response = await http.post(
        Uri.parse('$_uri'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN', // Thêm nếu cần
        },
        body: jsonEncode(branchMap),
     );

     if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return Branch.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
        } catch (e) {
           print("Lỗi decode created branch: $e \nBody: ${utf8.decode(response.bodyBytes)}");
           throw Exception('Lỗi giải mã chi nhánh vừa tạo.');
        }
     } else {
        print("Lỗi tạo branch. Status: ${response.statusCode} \nBody: ${utf8.decode(response.bodyBytes)}");
        throw Exception('Lỗi tạo chi nhánh (Mã: ${response.statusCode}) - ${utf8.decode(response.bodyBytes)}');
     }
  }

  // Cập nhật chi nhánh (PUT /api/branches/{id})
  Future<Branch> updateBranch(int branchId, Branch branch) async {
    // SỬA: Endpoint của backend là "/{id}", không phải "/update/{id}"
    final String updateUrl = '$_uri/$branchId'; 
    print("Đang cập nhật branch tại: $updateUrl");

     final Map<String, dynamic> branchMap = branch.toMap();
     branchMap.remove('id');
     branchMap['createdAt'] = branch.createdAt.toIso8601String();
     branchMap['updatedAt'] = DateTime.now().toIso8601String();

    final response = await http.put(
      Uri.parse(updateUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        // 'Authorization': 'Bearer YOUR_TOKEN', // Thêm nếu cần
      },
      body: jsonEncode(branchMap),
    );

    if (response.statusCode == 200) {
      try {
        return Branch.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
      } catch (e) {
         print("Lỗi decode updated branch: $e \nBody: ${utf8.decode(response.bodyBytes)}");
         throw Exception('Lỗi giải mã chi nhánh vừa cập nhật.');
      }
    } else {
        print("Lỗi update branch. Status: ${response.statusCode} \nBody: ${utf8.decode(response.bodyBytes)}");
        throw Exception('Lỗi cập nhật chi nhánh (Mã: ${response.statusCode}) - Backend có thể chưa hỗ trợ API này.');
    }
  }
  
Future<List<Branch>> fetchBranchesByCompanyId(int companyId) async {
    final response = await http.get(Uri.parse('$_uri/company/$companyId'),
        headers: {'Accept': 'application/json'}
    );

    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<Branch> branches = body.map((dynamic item) => Branch.fromMap(item as Map<String, dynamic>)).toList();
        return branches;
      } catch (e) {
         throw Exception('Lỗi giải mã dữ liệu chi nhánh.');
      }
    } else if (response.statusCode == 404) {
        return []; // Trả về danh sách rỗng nếu không tìm thấy
    } else {
      throw Exception('Lỗi tải danh sách chi nhánh (Mã: ${response.statusCode})');
    }
  }
}

// Riverpod provider cho BranchAPI
final branchApiProvider = Provider<BranchAPI>((ref) => BranchAPI());