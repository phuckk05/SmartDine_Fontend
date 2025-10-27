import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/table.dart';

//Link webservice
final uri1 = 'https://spring-boot-smartdine.onrender.com/api/tables';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/tables';

class TableAPI {
  // Your existing code here
  Future<List<Table>> fetchTables() async {
    final response = await http.get(
      Uri.parse('${uri2}'),
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
      print("Loi lay table: ${response.statusCode}");
      // In ra nội dung lỗi để xem chi tiết
      print("Noi dung loi: ${response.body}"); 
      return [];
    }
  }
}

final tableApiProvider = Provider<TableAPI>((ref) {
  return TableAPI();
});