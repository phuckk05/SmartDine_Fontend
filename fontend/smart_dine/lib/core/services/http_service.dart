import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 30);
  final int _maxRetries = 3;
  
  // 🟢 Configuration - Có thể tắt proxy cho mobile
  static const bool _useProxy = false; // MOBILE: Luôn để false
  static const String _proxyUrl = 'http://localhost:8080'; // Chỉ cho web dev

  // Headers mặc định
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'SmartDine-Flutter-App',
  };

  // Transform URL for proxy if needed (MOBILE: Always returns original URL)
  String _transformUrl(String url) {
    if (kIsWeb && _useProxy) {
      // Replace the original domain with proxy (Web only)
      return url.replaceFirst(
        'https://smartdine-backend-oq2x.onrender.com',
        _proxyUrl
      );
    }
    // 🟢 MOBILE: Luôn trả về URL gốc
    return url;
  }

  // Retry mechanism
  Future<http.Response> _executeWithRetry(Future<http.Response> Function() request) async {
    Exception? lastException;
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await request();
      } on SocketException catch (e) {
        lastException = Exception('Không có kết nối internet. Vui lòng kiểm tra mạng và thử lại.');
              } on HttpException catch (e) {
        lastException = Exception('Lỗi kết nối server. Vui lòng thử lại sau.');
              } on FormatException catch (e) {
        lastException = Exception('Dữ liệu trả về không hợp lệ.');
                break; // Don't retry for format exceptions
      } catch (e) {
        lastException = Exception('Lỗi kết nối: ${e.toString()}');
              }
      
      // Wait before retry (exponential backoff)
      if (attempt < _maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
        print('Retrying... attempt ${attempt + 1}');
      }
    }
    
    throw lastException ?? Exception('Unknown error occurred');
  }

  // GET request với retry và xử lý lỗi
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    return _executeWithRetry(() async {
      try {
        final transformedUrl = _transformUrl(url);
        print('Making GET request to: $transformedUrl'); // Debug log
        
        final response = await _client.get(
          Uri.parse(transformedUrl),
          headers: {..._headers, ...?headers},
        ).timeout(_timeout);
        
        print('Response status: ${response.statusCode}'); // Debug log
        return response;
      } catch (e) {
        print('HTTP GET Error: $e'); // Debug log
        rethrow;
      }
    });
  }

  // POST request với retry và xử lý lỗi
  Future<http.Response> post(String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _executeWithRetry(() async {
      try {
        print('Making POST request to: $url'); // Debug log
        
        final response = await _client.post(
          Uri.parse(url),
          headers: {..._headers, ...?headers},
          body: body,
        ).timeout(_timeout);
        
        print('Response status: ${response.statusCode}'); // Debug log
        return response;
      } catch (e) {
        print('HTTP POST Error: $e'); // Debug log
        rethrow;
      }
    });
  }

  // PUT request với retry và xử lý lỗi
  Future<http.Response> put(String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _executeWithRetry(() async {
      try {
        print('Making PUT request to: $url'); // Debug log
        
        final response = await _client.put(
          Uri.parse(url),
          headers: {..._headers, ...?headers},
          body: body,
        ).timeout(_timeout);
        
        print('Response status: ${response.statusCode}'); // Debug log
        return response;
      } catch (e) {
        print('HTTP PUT Error: $e'); // Debug log
        rethrow;
      }
    });
  }

  // DELETE request với retry và xử lý lỗi
  Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    return _executeWithRetry(() async {
      try {
        print('Making DELETE request to: $url'); // Debug log
        
        final response = await _client.delete(
          Uri.parse(url),
          headers: {..._headers, ...?headers},
        ).timeout(_timeout);
        
        print('Response status: ${response.statusCode}'); // Debug log
        return response;
      } catch (e) {
        print('HTTP DELETE Error: $e'); // Debug log
        rethrow;
      }
    });
  }

  // Kiểm tra kết nối internet
  Future<bool> checkConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('https://www.google.com'),
        headers: {'User-Agent': 'SmartDine-Flutter-App'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
            return false;
    }
  }

  // Test specific API endpoint
  Future<bool> testApiEndpoint(String url) async {
    try {
            final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      
            return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
            return false;
    }
  }

  // Xử lý response chung
  dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Không thể phân tích dữ liệu từ server.');
      }
    } else {
      String errorMessage = 'Lỗi server (${response.statusCode})';
      
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      } catch (e) {
        // Giữ thông báo lỗi mặc định nếu không thể parse response
      }
      
      throw Exception(errorMessage);
    }
  }

  // Đóng HTTP client
  void dispose() {
    _client.close();
  }
}