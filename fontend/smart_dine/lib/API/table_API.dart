import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/table.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/tables';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/tables';

class TableApi {
  //Lấy tất cả table by branchId
  Future<List<Table>> getTablesByBranchId(int branchId) async {
    final response = await http.get(
      Uri.parse('${uri2}/branch/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((table) => Table.fromMap(table as Map<String, dynamic>))
          .toList();
    }
        return [];
  }

  //Lấy table by id
  Future<Table?> getTableById(int tableId) async {
    final response = await http.get(
      Uri.parse('$uri2/$tableId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Table.fromMap(data);
    }
        return null;
  }

  Future<List<Table>> fetchTables() async {
    final response = await http.get(
      Uri.parse(uri2),
      // !!! LỖI 400 BAD REQUEST XẢY RA Ở ĐÂY !!!
      // Yêu cầu này bị thiếu thông tin mà backend cần,
      // ví dụ như 'branchId' hoặc 'Authorization'.
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Table.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
            // In ra nội dung lỗi để xem chi tiết
            return [];
    }
  }

  //Lay table theo branch id
  Future<List<Table>> fetchTablesByBranchId(int branchId) async {
    final response = await http.get(
      Uri.parse('$uri2/branch/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Table.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
            return []; // Trả về rỗng nếu không có hoặc lỗi
    }
  }
}

final tableApiProvider = Provider<TableApi>((ref) {
  return TableApi();
});
