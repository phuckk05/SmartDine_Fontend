import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/order_API.dart';
import 'package:mart_dine/API/reservation_API.dart';
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
final unpaidTablesByBranchProvider = FutureProvider.family<Set<int>, int>((
  ref,
  branchId,
) async {
  final orderApi = ref.watch(orderApiProvider);
  final orders = await orderApi.fetchOrdersByBranchIdToday(branchId);
  final activeTableIds =
      orders
          .where((order) => order.statusId == 2 || order.statusId == 4)
          .map((order) => order.tableId)
          .toSet();
  return activeTableIds;
});
final reservedTablesByBranchProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, branchId) async {
      final reservationApi = ref.watch(reservationApiProvider);
      return await reservationApi.getReservedTablesByBranch(branchId);
    });
