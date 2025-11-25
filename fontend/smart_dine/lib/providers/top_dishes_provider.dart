import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/menu_statistics_API.dart';
import '../core/realtime_notifier.dart';

// Provider cho top dishes statistics
final topDishesProvider = StateNotifierProvider.family<TopDishesNotifier, AsyncValue<List<Map<String, dynamic>>?>, int>((ref, branchId) {
  return TopDishesNotifier(
    ref.read(menuStatisticsApiProvider),
    branchId,
  );
});

class TopDishesNotifier extends RealtimeNotifier<List<Map<String, dynamic>>?> {
  final MenuStatisticsAPI _api;
  final int _branchId;

  TopDishesNotifier(this._api, this._branchId);

  @override
  Future<List<Map<String, dynamic>>?> loadData() async {
    try {
      final data = await _api.getTopDishesByBranch(branchId: _branchId);
      print('TopDishesNotifier: Loaded ${data?.length ?? 0} top dishes for branch $_branchId');
      return data;
    } catch (e) {
      print('TopDishesNotifier: Error loading top dishes: $e');
      return null;
    }
  }
}