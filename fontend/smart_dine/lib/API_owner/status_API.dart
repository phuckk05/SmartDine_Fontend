// file: lib/API/status_API.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final _baseUri = 'https://smartdine-backend-oq2x.onrender.com/api/user-statuses';

// Định nghĩa model chung cho Status
class StatusModel {
  final int id;
  final String code;
  final String name;
  StatusModel({required this.id, required this.code, required this.name});
  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      id: int.tryParse(map['id'].toString()) ?? 0,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
    );
  }
}

class StatusAPI {
  // Hàm helper chung để gọi API Status
  Future<List<StatusModel>> _fetchStatuses(String path) async {
     final response = await http.get(Uri.parse('$_baseUri/$path/all'),
        headers: {'Accept': 'application/json'});
     if (response.statusCode == 200) {
       List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
       return body.map((dynamic item) => StatusModel.fromMap(item)).toList();
     } else {
       throw Exception('Lỗi tải $path (Mã: ${response.statusCode})');
     }
  }

  // Lấy User Statuses (GET /api/user-statuses/all)
  Future<List<StatusModel>> fetchUserStatuses() async {
    return _fetchStatuses('user-statuses');
  }
  
  // (Thêm các hàm fetch status khác nếu cần)
  // Future<List<StatusModel>> fetchBranchStatuses() async { ... }
}

final statusApiProvider = Provider<StatusAPI>((ref) => StatusAPI());