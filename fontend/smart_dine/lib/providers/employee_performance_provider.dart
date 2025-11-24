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
      

      
      // Load employee performance and overview in parallel (không cần trips data nữa)
      final futures = await Future.wait([
        _api.getEmployeePerformance(_branchId, period: period),
        _api.getBranchPerformanceOverview(_branchId),
      ]);
      
      final employeeList = futures[0] as List<Map<String, dynamic>>?;
      final overview = futures[1] as Map<String, dynamic>?;
      
      print('EmployeePerformanceNotifier: employeeList: $employeeList');
      print('EmployeePerformanceNotifier: overview: $overview');
      
      if (employeeList != null) {
        // Lọc chỉ hiển thị nhân viên có role phục vụ, đầu bếp, thu ngân
        final filteredEmployeeList = employeeList.where((employee) {
          final roleId = employee['roleId'] ?? employee['role'];
          // Map role ID đơn giản: 1=phục vụ, 2=đầu bếp, 3=thu ngân, etc.
          final role = roleId is int ? roleId : (roleId?.toString().toLowerCase() ?? '');
          return role == 1 || role == '1' || // Phục vụ
                 role == 2 || role == '2' || // Đầu bếp  
                 role == 3 || role == '3' || // Thu ngân
                 (role is String && (
                   role.contains('phục vụ') || role.contains('phuc vu') ||
                   role.contains('đầu bếp') || role.contains('dau bep') ||
                   role.contains('chef') || role.contains('thu ngân') ||
                   role.contains('thu ngan') || role.contains('cashier') ||
                   role.contains('staff') || role.contains('waiter')
                 ));
        }).toList();
        
        print('EmployeePerformanceNotifier: Filtered employees from ${employeeList.length} to ${filteredEmployeeList.length}');
        
        final data = EmployeePerformanceData(
          employeeList: filteredEmployeeList,
          tripsData: [], // Không còn dùng biểu đồ
          overview: overview,
          selectedPeriod: period,
        );
        
        print('EmployeePerformanceNotifier: Created data with ${filteredEmployeeList.length} employees from API');
        state = AsyncValue.data(data);
      } else {
        // Không tạo dữ liệu mẫu, để empty state
        final emptyData = EmployeePerformanceData(
          employeeList: [],
          tripsData: [],
          overview: null,
          selectedPeriod: period,
        );
        print('EmployeePerformanceNotifier: No employee data available');
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