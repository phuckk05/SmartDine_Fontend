import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SimpleHttpService {
  static final SimpleHttpService _instance = SimpleHttpService._internal();
  factory SimpleHttpService() => _instance;
  SimpleHttpService._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 30);

  // Headers mặc định cho mobile
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET request đơn giản
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {..._headers, ...?headers},
      ).timeout(_timeout);
      return response;
    } on SocketException {
      throw Exception('Không có kết nối internet');
    } on HttpException {
      throw Exception('Lỗi kết nối server');
    } on FormatException {
      throw Exception('Dữ liệu không hợp lệ');
    }
  }

  // POST request đơn giản
  Future<http.Response> post(String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {..._headers, ...?headers},
        body: body is String ? body : json.encode(body),
      ).timeout(_timeout);
      return response;
    } on SocketException {
      throw Exception('Không có kết nối internet');
    } on HttpException {
      throw Exception('Lỗi kết nối server');
    } on FormatException {
      throw Exception('Dữ liệu không hợp lệ');
    }
  }

  // PUT request đơn giản
  Future<http.Response> put(String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {..._headers, ...?headers},
        body: body is String ? body : json.encode(body),
      ).timeout(_timeout);
      return response;
    } on SocketException {
      throw Exception('Không có kết nối internet');
    } on HttpException {
      throw Exception('Lỗi kết nối server');
    } on FormatException {
      throw Exception('Dữ liệu không hợp lệ');
    }
  }

  // DELETE request đơn giản
  Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: {..._headers, ...?headers},
      ).timeout(_timeout);
      return response;
    } on SocketException {
      throw Exception('Không có kết nối internet');
    } on HttpException {
      throw Exception('Lỗi kết nối server');
    } on FormatException {
      throw Exception('Dữ liệu không hợp lệ');
    }
  }

  // Xử lý response đơn giản
  dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }
    
    String errorMessage = 'Lỗi server (${response.statusCode})';
    try {
      final errorData = json.decode(response.body);
      if (errorData['message'] != null) {
        errorMessage = errorData['message'];
      }
    } catch (e) {
      // Keep default error message
    }
    
    throw Exception(errorMessage);
  }

  // Đóng client
  void dispose() {
    _client.close();
  }
}