import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/table.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/tables';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/tables';

class TableApi {
  //Lấy tất cả table by branchId
  Future<List<DiningTable>> getTablesByBranchId(int branchId) async {
    final response = await http.get(
      Uri.parse('${uri2}/branch/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((table) => DiningTable.fromMap(table as Map<String, dynamic>))
          .toList();
    }
    print("loi lấy table ids: ${response.statusCode}");
    return [];
  }

  //Lấy table by id
  Future<DiningTable?> getTableById(int tableId) async {
    final response = await http.get(
      Uri.parse('$uri2/$tableId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return DiningTable.fromMap(data);
    }
    print("loi lay table by id : ${response.statusCode}");
    return null;
  }

  Future<List<DiningTable>> fetchTables() async {
    final response = await http.get(
      Uri.parse('${uri2}/all'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => DiningTable.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      print("Loi lay table: ${response.statusCode}");
      return [];
    }
  }
}

final tableApiProvider = Provider<TableApi>((ref) {
  return TableApi();
});
