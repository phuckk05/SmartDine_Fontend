import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/table_API.dart';
import 'package:mart_dine/models/table.dart';

class TableNotifier extends StateNotifier<List<DiningTable>> {
  final TableApi tableAPI;
  TableNotifier(this.tableAPI) : super([]);

  Set<DiningTable> build() {
    return const {};
  }

  //Load danh sách bàn
  Future<void> loadTables(int branchId) async {
    final tables = await tableAPI.getTablesByBranchId(branchId);
    state = tables;
  }

  //Lấy name table by id
  String? getTableNameById(int? tableId) {
    if (tableId == null) return null;
    try {
      final table = state.firstWhere((table) => table.id == tableId);
      return table.name;
    } catch (_) {
      return null;
    }
  }
}

final tableNotifierProvider =
    StateNotifierProvider<TableNotifier, List<DiningTable>>((ref) {
      return TableNotifier(ref.read(tableApiProvider));
    });
