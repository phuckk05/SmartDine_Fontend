import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chef.dart';

const chefBaseUrl = 'https://smartdine-backend-oq2x.onrender.com/api/chef';

class ChefAPI {
  Future<Chef?> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$chefBaseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Nếu API có bọc dữ liệu
        final chefData = jsonData['data'] ?? jsonData;

        return Chef.fromJson(chefData);
      } else {
        print("Lỗi khi lấy chef theo id: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi gọi API getById: $e");
    }
    return null;
  }
}

final chefApiProvider = Provider<ChefAPI>((ref) => ChefAPI());
