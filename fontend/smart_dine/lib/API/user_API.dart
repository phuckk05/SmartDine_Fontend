import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/users';

class UserAPI {
  //Tạo user
  Future<User?> create(User user) async {
    final response = await http.post(
      Uri.parse('${_uri}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toMap()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromMap(data);
    }
    return null;
  }
}

//userApiProvider
final userApiProvider = Provider<UserAPI>((ref) => UserAPI());
