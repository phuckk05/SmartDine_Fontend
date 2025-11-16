import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/table.dart' as table_model;
import '../core/services/http_service.dart';

final tableManagementApiProvider = Provider((ref) => TableManagementAPI());

class TableManagementAPI {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';

  // Helper để parse response
  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    }
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  // Lấy tất cả bàn
  Future<List<table_model.Table>?> getAllTables() async {
    try {
      final response = await _httpService.get('$baseUrl/tables');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> tables;
        if (data is Map<String, dynamic> && data['data'] != null) {
          tables = data['data'];
        } else if (data is List) {
          tables = data;
        } else {
          return [];
        }
        return tables.map((json) => table_model.Table.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }

  // Lấy danh sách bàn theo chi nhánh
  Future<List<table_model.Table>?> getTablesByBranch(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/tables/branch/$branchId');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> tables;
        if (data is Map<String, dynamic> && data['data'] != null) {
          tables = data['data'];
        } else if (data is List) {
          tables = data;
        } else {
          return [];
        }
        return tables.map((json) => table_model.Table.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }

  // Lấy thông tin bàn theo ID
  Future<table_model.Table?> getTableById(int tableId) async {
    try {
      final response = await _httpService.get('$baseUrl/tables/$tableId');
      final data = _parseResponse(response);
      
      if (data != null) {
        if (data is Map<String, dynamic>) {
          if (data['data'] != null) {
            return table_model.Table.fromJson(data['data']);
          } else {
            return table_model.Table.fromJson(data);
          }
        }
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Tạo bàn mới
  Future<table_model.Table?> createTable(table_model.Table table) async {
    try {
      final response = await _httpService.post(
        '$baseUrl/tables',
        body: jsonEncode(table.toJson()),
      );
      final data = _parseResponse(response);
      
      if (data != null && data is Map<String, dynamic>) {
        if (data['data'] != null) {
          return table_model.Table.fromJson(data['data']);
        } else {
          return table_model.Table.fromJson(data);
        }
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Cập nhật thông tin bàn
  Future<table_model.Table?> updateTable(int tableId, table_model.Table table) async {
    try {
      final response = await _httpService.put(
        '$baseUrl/tables/$tableId',
        body: jsonEncode(table.toJson()),
      );
      final data = _parseResponse(response);
      
      if (data != null && data is Map<String, dynamic>) {
        if (data['data'] != null) {
          return table_model.Table.fromJson(data['data']);
        } else {
          return table_model.Table.fromJson(data);
        }
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Xóa bàn
  Future<bool> deleteTable(int tableId) async {
    try {
      final response = await _httpService.delete('$baseUrl/tables/$tableId');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
            return false;
    }
  }

  // Lấy thống kê độ chiếm chỗ theo chi nhánh
  Future<Map<String, dynamic>?> getOccupancyStatistics(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/tables/occupancy/branch/$branchId');
      final data = _parseResponse(response);
      
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy thống kê độ sử dụng theo chi nhánh
  Future<Map<String, dynamic>?> getUtilizationStatistics(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/tables/utilization/branch/$branchId');
      final data = _parseResponse(response);
      
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy danh sách bàn còn trống theo chi nhánh
  Future<List<table_model.Table>?> getAvailableTables(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/tables/availability/branch/$branchId');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> tables;
        if (data is Map<String, dynamic> && data['data'] != null) {
          tables = data['data'];
        } else if (data is List) {
          tables = data;
        } else {
          return [];
        }
        return tables.map((json) => table_model.Table.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }

  // Lấy thống kê bàn theo chi nhánh
  Future<Map<String, dynamic>?> getTableStatistics(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/tables/statistics/branch/$branchId');
      final data = _parseResponse(response);
      
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy danh sách loại bàn
  Future<List<Map<String, dynamic>>?> getTableTypes() async {
    try {
      final response = await _httpService.get('$baseUrl/table-types/all');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> types;
        if (data is Map<String, dynamic> && data['data'] != null) {
          types = data['data'];
        } else if (data is List) {
          types = data;
        } else {
          return [];
        }
        return types.map((type) => Map<String, dynamic>.from(type)).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }

  // Lấy danh sách trạng thái bàn
  Future<List<Map<String, dynamic>>?> getTableStatuses() async {
    try {
      final response = await _httpService.get('$baseUrl/table-statuses/all');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> statuses;
        if (data is Map<String, dynamic> && data['data'] != null) {
          statuses = data['data'];
        } else if (data is List) {
          statuses = data;
        } else {
          return [];
        }
        return statuses.map((status) => Map<String, dynamic>.from(status)).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }

  // Cập nhật trạng thái bàn
  Future<bool> updateTableStatus(int tableId, int statusId) async {
    try {
      final response = await _httpService.put(
        '$baseUrl/tables/$tableId/status',
        body: jsonEncode({'statusId': statusId, 'status_id': statusId}),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
            return false;
    }
  }

  // Lấy orders hiện tại của bàn
  Future<List<Map<String, dynamic>>?> getTableCurrentOrders(int tableId) async {
    try {
      final response = await _httpService.get('$baseUrl/tables/$tableId/orders/current');
      final data = _parseResponse(response);
      
      if (data != null) {
        List<dynamic> orders;
        if (data is Map<String, dynamic> && data['data'] != null) {
          orders = data['data'];
        } else if (data is List) {
          orders = data;
        } else {
          return [];
        }
        return orders.map((order) => Map<String, dynamic>.from(order)).toList();
      }
      return [];
    } catch (e) {
            return null;
    }
  }
}