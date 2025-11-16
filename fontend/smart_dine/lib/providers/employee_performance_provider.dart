import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/employee_performance_API.dart';

// Provider cho employee performance
final employeePerformanceProvider = StateNotifierProvider.family<EmployeePerformanceNotifier, AsyncValue<EmployeePerformanceData?>, int>((ref, branchId) {
  return EmployeePerformanceNotifier(
    ref.read(employeePerformanceApiProvider),
    branchId,
  );
});

class EmployeePerformanceData {
  final List<Map<String, dynamic>> employeeList;
  final List<Map<String, dynamic>> tripsData;
  final Map<String, dynamic>? overview;
  final String selectedPeriod;

  EmployeePerformanceData({
    required this.employeeList,
    required this.tripsData,
    this.overview,
    this.selectedPeriod = 'week',
  });

  bool get isEmpty => employeeList.isEmpty && tripsData.isEmpty;
}

class EmployeePerformanceNotifier extends StateNotifier<AsyncValue<EmployeePerformanceData?>> {
  final EmployeePerformanceAPI _api;
  final int _branchId;

  EmployeePerformanceNotifier(this._api, this._branchId) : super(const AsyncValue.loading()) {
    loadPerformanceData();
  }

  Future<void> loadPerformanceData({String period = 'week'}) async {
    try {
      state = const AsyncValue.loading();
      

      
      // Load employee performance, trips data, and overview in parallel
      final futures = await Future.wait([
        _api.getEmployeePerformance(_branchId, period: period),
        _api.getTripsData(_branchId, period: period),
        _api.getBranchPerformanceOverview(_branchId),
      ]);
      
      final employeeList = futures[0] as List<Map<String, dynamic>>?;
      final tripsData = futures[1] as List<Map<String, dynamic>>?;
      final overview = futures[2] as Map<String, dynamic>?;
      
      if (employeeList != null || tripsData != null) {
        final data = EmployeePerformanceData(
          employeeList: employeeList ?? [],
          tripsData: tripsData ?? [],
          overview: overview,
          selectedPeriod: period,
        );
        

        state = AsyncValue.data(data);
      } else {

        final emptyData = EmployeePerformanceData(
          employeeList: [],
          tripsData: [],
          overview: null,
          selectedPeriod: period,
        );
        state = AsyncValue.data(emptyData);
      }
    } catch (error, stackTrace) {

      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh({String period = 'week'}) async {
    await loadPerformanceData(period: period);
  }

  Future<void> changePeriod(String newPeriod) async {
    await loadPerformanceData(period: newPeriod);
  }
}