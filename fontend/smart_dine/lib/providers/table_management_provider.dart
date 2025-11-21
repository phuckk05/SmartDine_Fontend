import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/table_management_API.dart';
import '../models/table.dart' as table_model;
import 'user_session_provider.dart';

// Provider cho table management theo branch
final tableManagementProvider = StateNotifierProvider.family<TableManagementNotifier, AsyncValue<List<table_model.Table>>, int>((ref, branchId) {
  return TableManagementNotifier(
    ref.read(tableManagementApiProvider),
    branchId,
  );
});

class TableManagementNotifier extends StateNotifier<AsyncValue<List<table_model.Table>>> {
  final TableManagementAPI _api;
  final int _branchId;

  TableManagementNotifier(this._api, this._branchId) : super(const AsyncValue.loading()) {
    loadTables();
  }

  Future<void> loadTables() async {
    try {
      state = const AsyncValue.loading();
      final tables = await _api.getTablesByBranch(_branchId);
      
      if (tables != null) {
        state = AsyncValue.data(tables);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

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
        // Refresh the table list
        await loadTables();
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
        // Refresh the table list
        await loadTables();
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
        // Refresh the table list
        await loadTables();
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

// Provider cho table types theo branch
final tableTypesProvider = StateNotifierProvider.family<TableTypesNotifier, AsyncValue<List<table_model.TableType>>, int>((ref, branchId) {
  final companyId = ref.watch(currentCompanyIdProvider);
  return TableTypesNotifier(
    ref.read(tableManagementApiProvider),
    branchId,
    companyId,
  );
});

class TableTypesNotifier extends StateNotifier<AsyncValue<List<table_model.TableType>>> {
  final TableManagementAPI _api;
  final int _branchId;
  final int? _companyId;

  TableTypesNotifier(this._api, this._branchId, this._companyId) : super(const AsyncValue.loading()) {
    loadTableTypes();
  }

  Future<void> loadTableTypes() async {
    try {
      state = const AsyncValue.loading();
      final types = await _api.getTableTypesByBranch(_branchId);
      
      if (types != null) {
        final tableTypes = types.map((type) => table_model.TableType.fromJson(type)).toList();
        state = AsyncValue.data(tableTypes);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

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
        await loadTableTypes(); // Refresh list
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
        await loadTableTypes(); // Refresh list
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
        await loadTableTypes(); // Refresh list
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}