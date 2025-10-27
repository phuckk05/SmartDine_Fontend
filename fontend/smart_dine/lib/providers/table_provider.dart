import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/order_API.dart';
import 'package:mart_dine/API/table_API.dart';
import 'package:mart_dine/models/table.dart';

class TableProvider extends StateNotifier<List<Table>> {
  final TableAPI tableAPI;
  TableProvider(this.tableAPI) : super([]);

  //Lấy danh sách bàn
  void getAll(int branchId) async {
    final tables = await tableAPI.fetchTablesByBranchId(branchId);
    state = tables.isNotEmpty ? tables : [];
  }

  //Thêm bàn
  void addTable(Table table) {
    state = [...state, table];
  }

  //Cập nhật bàn
  void updateTable(Table updatedTable) {
    state = [
      for (final table in state)
        if (table.id == updatedTable.id) updatedTable else table,
    ];
  }

  //Xóa bàn
  void deleteTable(int tableId) {
    state = state.where((table) => table.id != tableId).toList();
  }
}

final tableNotifierProvider = StateNotifierProvider<TableProvider, List<Table>>(
  (ref) {
    return TableProvider(ref.watch(tableApiProvider));
  },
);

// FutureProvider for unpaid table IDs today
final getUnpaidTableIdsToday = FutureProvider<List<int>>((ref) async {
  final orderApi = ref.watch(orderApiProvider);
  return orderApi.fetchUnpaidTableIdsToday();
});
