import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/table_management_API.dart';
import '../API/branch_API.dart';
import '../models/table.dart' as table_model;
import '../models/branch.dart';
import '../core/realtime_notifier.dart';

// Provider cho danh sách table statuses
final tableStatusesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(tableManagementApiProvider);
  final statuses = await api.getTableStatuses();
  return statuses ?? [
    {'id': 1, 'code': 'EMPTY', 'name': 'Trống'},
    {'id': 2, 'code': 'OCCUPIED', 'name': 'Đang sử dụng'},
    {'id': 3, 'code': 'RESERVED', 'name': 'Đã đặt'},
    {'id': 4, 'code': 'MAINTENANCE', 'name': 'Bảo trì'},
  ];
});

// Provider cho danh sách table types theo branch
final tableTypesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, branchId) async {
  final api = ref.read(tableManagementApiProvider);
  final types = await api.getTableTypesByBranch(branchId);
  return types ?? [];
});

// Provider cho table management theo branch
final tableManagementProvider = StateNotifierProvider.family<TableManagementNotifier, AsyncValue<List<table_model.Table>>, int>((ref, branchId) {
  return TableManagementNotifier(
    ref.read(tableManagementApiProvider),
    ref.read(branchApiProvider),
    branchId,
  );
});

class TableManagementNotifier extends RealtimeNotifier<List<table_model.Table>> {
  final TableManagementAPI _api;
  final BranchAPI _branchApi;
  final int _branchId;

  TableManagementNotifier(this._api, this._branchApi, this._branchId);

  @override
  Future<List<table_model.Table>> loadData() async {
    final tables = await _api.getTablesByBranch(_branchId);
    if (tables == null) return [];
    
    // Enrich với branch name và type names
    final branch = await _branchApi.getBranchById(_branchId.toString());
    final types = await _api.getTableTypesByBranch(_branchId);
    final statuses = await _api.getTableStatuses();
    
    final enrichedTables = tables.map((table) {
      final type = types?.firstWhere((t) => t['id'] == table.typeId, orElse: () => {});
      final status = statuses?.firstWhere((s) => s['id'] == table.statusId, orElse: () => {});
      
      return table.copyWith(
        branchName: branch?.name ?? 'Chi nhánh $_branchId',
        typeName: type?['name'] ?? 'Loại bàn ${table.typeId}',
        statusName: status?['name'] ?? 'Trạng thái ${table.statusId}',
      );
    }).toList();
    
    return enrichedTables;
  }

  @override
  Duration get pollingInterval => const Duration(seconds: 15); // Update every 15 seconds for table management

  Future<table_model.Table?> getTableById(int tableId) async {
    try {
      return await _api.getTableById(tableId);
    } catch (error) {
      return null;
    }
  }

  Future<bool> createTable(table_model.Table table) async {
    try {
      final createdTable = await _api.createTable(table);
      if (createdTable != null) {
        // Refresh the table list immediately
        await refresh();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> updateTable(int tableId, table_model.Table table) async {
    try {
      final updatedTable = await _api.updateTable(tableId, table);
      if (updatedTable != null) {
        // Refresh the table list immediately
        await refresh();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> deleteTable(int tableId) async {
    try {
      final success = await _api.deleteTable(tableId);
      if (success) {
        // Refresh the table list immediately
        await refresh();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}

// Provider cho tất cả tables (không theo branch)
final allTablesProvider = FutureProvider<List<table_model.Table>>((ref) async {
  final api = ref.read(tableManagementApiProvider);
  final tables = await api.getAllTables();
  return tables ?? [];
});

// Provider cho một table cụ thể
final tableDetailProvider = FutureProvider.family<table_model.Table?, int>((ref, tableId) async {
  final api = ref.read(tableManagementApiProvider);
  return api.getTableById(tableId);
});

class TableTypesNotifier extends RealtimeNotifier<List<table_model.TableType>> {
  final TableManagementAPI _api;
  final int _branchId;
  final int? _companyId;

  TableTypesNotifier(this._api, this._branchId, this._companyId);

  @override
  Future<List<table_model.TableType>> loadData() async {
    final types = await _api.getTableTypesByBranch(_branchId);
    if (types != null) {
      return types.map((type) => table_model.TableType.fromJson(type)).toList();
    }
    return [];
  }

  @override
  Duration get pollingInterval => const Duration(seconds: 10); // More frequent updates for table types

  Future<bool> createTableType(String name, String code) async {
    try {
      final tableTypeData = {
        'name': name,
        'code': code,
        'branchId': _branchId,
        if (_companyId != null) 'companyId': _companyId,
      };

      final result = await _api.createTableType(_branchId, tableTypeData);
      if (result != null) {
        await refresh(); // Refresh list immediately
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> updateTableType(int typeId, String name, String code) async {
    try {
      final tableTypeData = {
        'name': name,
        'code': code,
        'branchId': _branchId,
        if (_companyId != null) 'companyId': _companyId,
      };

      final result = await _api.updateTableType(typeId, tableTypeData);
      if (result != null) {
        await refresh(); // Refresh list immediately
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> deleteTableType(int typeId) async {
    try {
      final success = await _api.deleteTableType(typeId);
      if (success) {
        await refresh(); // Refresh list immediately
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}